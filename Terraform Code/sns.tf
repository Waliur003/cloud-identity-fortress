//Create SNS topic named "IdentityFortressAlerts"
resource "aws_sns_topic" "identity_alerts_topic" {
  name = var.topic_name

  tags = {
    Name        = "IdentityFortressAlerts"
    Environment = "Security-Enterprise"
  }
}

//Create SNS topic subscription for email address
resource "aws_sns_topic_subscription" "identity_alerts_subscription" {
  topic_arn = aws_sns_topic.identity_alerts_topic.arn
  protocol  = "email"
  endpoint  = var.sns_topic_subscription
}