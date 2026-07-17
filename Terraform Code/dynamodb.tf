//Create DynamoDB table named "IdentityRisksTable"
resource "aws_dynamodb_table" "identity_risks_table" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"

  hash_key       = "FindingId"
  range_key      = "Timestamp"

    attribute {
    name = "FindingId"
    type = "S"
    }

    attribute {
        name = "Timestamp"
        type = "S"
    }

  tags = {
    Name        = "IdentityRisksTable"
    Environment = "Security-Enterprise"
  }
}