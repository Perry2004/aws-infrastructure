output "iam_admin_users" {
  description = "Details of created IAM Identity Center admin users"
  value = { for i in range(length(var.iam_admin_users)) :
    var.iam_admin_users[i].username => {
      user_id      = aws_identitystore_user.users[i].user_id
      display_name = aws_identitystore_user.users[i].display_name
      email        = aws_identitystore_user.users[i].emails[0].value
    }
  }
  sensitive = true
}
