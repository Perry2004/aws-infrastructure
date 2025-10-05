data "aws_ssoadmin_instances" "this" {}

data "aws_caller_identity" "current" {}

resource "aws_identitystore_user" "users" {
  count = length(var.iam_admin_users)

  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]

  user_name = var.iam_admin_users[count.index].username

  display_name = var.iam_admin_users[count.index].display_name

  name {
    given_name  = var.iam_admin_users[count.index].first_name
    family_name = var.iam_admin_users[count.index].last_name
  }

  emails {
    value = var.iam_admin_users[count.index].email
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
  count = length(var.iam_admin_users)

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_id       = aws_identitystore_user.users[count.index].user_id
  principal_type     = "USER"
  target_id          = data.aws_caller_identity.current.account_id
  target_type        = "AWS_ACCOUNT"
}
