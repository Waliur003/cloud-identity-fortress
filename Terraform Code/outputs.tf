//Output the Trail Name
output "trail_name" {
  value = aws_cloudtrail.organization_identity_trail.name
}


//Output the Bucket Name
output "bucket_name" {
  value = aws_s3_bucket.cloudtrail_logs.bucket
}


//Output the CloudWatch Log Group Name
output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.cloudtrail_logs.name
}


//Output the DynamoDB Table Name
output "dynamodb_table_name" {
  value = aws_dynamodb_table.identity_risks_table.name
}


//Output the SNS Topic ARN
output "sns_topic_arn" {
  value = aws_sns_topic.identity_alerts_topic.arn
}


//Output the SNS Topic Name
output "sns_topic_name" {
  value = aws_sns_topic.identity_alerts_topic.name
}


//Output the Lambda Function Name
output "lambda_function_name" {
  value = aws_lambda_function.iam_governance_analyzer.function_name
}


//Output the EventBridge Rule ARN.
output "eventbridge_rule_arn" {
  value = aws_cloudwatch_event_rule.route_identity_threats.arn
}