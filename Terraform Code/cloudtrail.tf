# Declare caller identity data source to obtain account metadata dynamically
data "aws_caller_identity" "current" {}

# Create S3 bucket for CloudTrail logs named "org-identity-fortress-audit-logs"
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket        = var.s3_bucket_name
  force_destroy = true # Allows clean tear-downs of test logs during development

  tags = {
    Name        = var.s3_bucket_name
    Environment = "Security-Enterprise"
  }
}

# Enable Bucket Versioning for S3 bucket "org-identity-fortress-audit-logs"
resource "aws_s3_bucket_versioning" "cloudtrail_logs_versioning" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block Public Access for S3 bucket "org-identity-fortress-audit-logs"
resource "aws_s3_bucket_public_access_block" "cloudtrail_logs_public_access_block" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Implement S3 bucket policy to authorize CloudTrail delivery and verification
resource "aws_s3_bucket_policy" "cloudtrail_logs_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail_logs.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/*" # Widened to support all organizational accounts
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# Create CloudWatch Log Group for CloudTrail logs
resource "aws_cloudwatch_log_group" "cloudtrail_logs" {
  name              = "/aws/cloudtrail/IdentityFortressLogs"
  retention_in_days = 90

  tags = {
    Name        = "org-identity-fortress-audit-logs"
    Environment = "Security-Enterprise"
  }
}

# Configure an aws_iam_role that trusts cloudtrail.amazonaws.com
resource "aws_iam_role" "cloudtrail_logs_role" {
  name = "CloudTrailLogsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# An aws_iam_role_policy granting access to run logs:CreateLogStream and logs:PutLogEvents
resource "aws_iam_role_policy" "cloudtrail_logs_role_policy" {
  name = "CloudTrailLogsRolePolicy"
  role = aws_iam_role.cloudtrail_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudtrail_logs.arn}:*"
      }
    ]
  })
}

# Create CloudTrail trail named "OrganizationIdentityTrail"
resource "aws_cloudtrail" "organization_identity_trail" {
  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail_logs.arn}:*" # Appended stream wildcard
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_logs_role.arn
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = true # Successfully targets AWS Organizations
  enable_log_file_validation    = true

  tags = {
    Name        = var.trail_name
    Environment = "Security-Enterprise"
  }
}
