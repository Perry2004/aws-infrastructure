output "iam_admin_users" {
  description = "Details of created IAM Identity Center admin users"
  value = { for user in aws_identitystore_user.users :
    user.user_name => {
      user_id      = user.user_id
      display_name = user.display_name
      email        = user.emails[0].value
    }
  }
}
