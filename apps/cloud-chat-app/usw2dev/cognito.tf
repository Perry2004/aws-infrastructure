resource "aws_cognito_user_pool" "cca" {
  name = "${var.app_short_name}-user-pool"
}
