//Declare Provider for aws region
variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "us-east-1"
}


//Declare variable for trail name
variable "trail_name" {
  default = "OrganizationIdentityTrail"
}


//Declare variable for S3 bucket name
variable "s3_bucket_name" {
  description = "The name of the S3 bucket to store CloudTrail logs."
  type        = string
  default     = "organization-identity-trail-logs"
}


//Declare variable for DynamoDB table name
variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table to store identity risks."
  type        = string
  default     = "IdentityRisksTable"
}


//Declare SNS Topic Name variable
variable "topic_name" {
  description = "The name of the SNS topic to send alerts."
  type        = string
  default     = "IdentityAlertsTopic"
}

//Declare Sns topic subscription variable
variable "sns_topic_subscription" {
  description = "The email address to subscribe to the SNS topic."
  type        = string
  default     = "waliurrahmansun003@gmail.com"
}