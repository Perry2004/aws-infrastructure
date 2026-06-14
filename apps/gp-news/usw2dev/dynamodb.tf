resource "aws_dynamodb_table" "briefing_history" {
  name         = "${var.app_name}-${var.env_name}-briefing-history"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "briefing_history_id"
  range_key    = "briefing_entry_id"

  attribute {
    name = "briefing_history_id"
    type = "S"
  }

  attribute {
    name = "briefing_entry_id"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }
}
