//Create IAM role for Lambda function named "IdentityFortressLambdaRole"
resource "aws_iam_role" "lambda_role" {
  name = "IdentityFortressLambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

//Configure inline role policy to grant DynamoDB write actions and SNS publish permissions
resource "aws_iam_role_policy" "lambda_role_policy" {
  name = "IdentityFortressLambdaRolePolicy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "sns:Publish"
        ]
        Resource = [
          aws_dynamodb_table.identity_risks_table.arn,
          aws_sns_topic.identity_alerts_topic.arn
        ]
      }
    ]
  })
}

//Create Lambda function named "IAMGovernanceAnalyzerFunction"
resource "aws_lambda_function" "iam_governance_analyzer" {
  function_name = "IAMGovernanceAnalyzerFunction"
  role          = aws_iam_role.lambda_role.arn
  handler       = "IAMGovernanceAnalyzerFunction.lambda_handler" # Realigned to match python entry function
  runtime       = "python3.12"

  filename         = "IAMGovernanceAnalyzerFunction.zip"
  source_code_hash = filebase64sha256("IAMGovernanceAnalyzerFunction.zip")

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name # Key updated from DYNAMODB_TABLE_NAME to TABLE_NAME
      TOPIC_ARN  = aws_sns_topic.identity_alerts_topic.arn
    }
  }

  tags = {
    Name        = "IAMGovernanceAnalyzerFunction"
    Environment = "Security-Enterprise"
  }
}