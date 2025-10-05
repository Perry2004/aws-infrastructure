data "aws_ssoadmin_instances" "this" {}

data "aws_caller_identity" "current" {}

resource "aws_identitystore_user" "users" {
  for_each = { for user in var.iam_admin_users : user.username => user }

  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]

  user_name = each.value.username

  display_name = each.value.display_name

  name {
    given_name  = each.value.first_name
    family_name = each.value.last_name
  }

  emails {
    value = each.value.email
  }
}

resource "aws_ssoadmin_permission_set" "admin" {
  name         = "AdministratorAccess"
  instance_arn = data.aws_ssoadmin_instances.this.arns[0]
}

resource "aws_ssoadmin_managed_policy_attachment" "admin" {
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
}

resource "aws_ssoadmin_account_assignment" "admin" {
  for_each = aws_identitystore_user.users

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_id       = each.value.user_id
  principal_type     = "USER"
  target_id          = data.aws_caller_identity.current.account_id
  target_type        = "AWS_ACCOUNT"
}
