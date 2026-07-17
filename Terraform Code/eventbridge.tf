//Create cloudwatch event rule named "RouteIdentityThreats" to trigger on high-risk identity modifications in real-time
resource "aws_cloudwatch_event_rule" "route_identity_threats" {
  name        = "RouteIdentityThreats"
  description = "Intercepts root sign-ins and risky IAM privilege modifications in real-time"
  
  event_pattern = jsonencode({
    source = ["aws.iam", "aws.signin"]
    detail-type = [
      "AWS API Call via CloudTrail",
      "AWS Console Sign-In via CloudTrail"
    ]
    "$or" = [
      {
        detail = {
          userIdentity = {
            type = ["Root"]
          }
        }
      },
      {
        detail = {
          eventName = [
            "ConsoleLogin",
            "CreateAccessKey",
            "CreateUser",
            "AttachUserPolicy",
            "PutUserPolicy",
            "CreatePolicyVersion",
            "UpdateAccessKey"
          ]
        }
      }
    ]
  })

  tags = {
    Name        = "RouteIdentityThreats"
    Environment = "Security-Enterprise"
  }
}


//Create cloudwatch event target to link the event rule to the Lambda function
resource "aws_cloudwatch_event_target" "route_identity_threats_target" {
  rule      = aws_cloudwatch_event_rule.route_identity_threats.name
  target_id = "IAMGovernanceAnalyzerFunction"
  arn       = aws_lambda_function.iam_governance_analyzer.arn
}

//Create aws_lambda_permission to allow the CloudWatch event rule to invoke the Lambda function
resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.iam_governance_analyzer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.route_identity_threats.arn
}