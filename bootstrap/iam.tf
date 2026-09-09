locals {
  engineer_assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowEngineerAssumeRole"
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent" : "true"
          },
          IpAddress = {
            "aws:SourceIp" : var.engineer_allowed_ip_ranges
          }
        }
        Principal = {
          AWS = [for email in var.engineer_email_addresses :
            "arn:aws:iam::${var.base_user_account_id}:user/${email}"
          ]
        }
      }
    ]
  }
}

resource "aws_iam_role" "admin" {
  name               = "Admin"
  assume_role_policy = jsonencode(local.engineer_assume_role_policy)
}

resource "aws_iam_role_policy_attachment" "allow_admin" {
  role       = aws_iam_role.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "power_user" {
  name               = "PowerUser"
  assume_role_policy = jsonencode(local.engineer_assume_role_policy)
}

resource "aws_iam_policy" "power_user_access" {
  name        = "PowerUserAccess"
  path        = "/"
  description = "Access to everything except most account and permissions actions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        NotAction = [
          "iam:*",
          "organizations:*",
          "account:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "account:GetAccountInformation",
          "account:GetPrimaryEmail",
          "account:ListRegions",
          "iam:CreateServiceLinkedRole",
          "iam:DeleteServiceLinkedRole",
          "iam:ListRoles",
          "organizations:DescribeEffectivePolicy",
          "organizations:DescribeOrganization"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "power_user_access" {
  role       = aws_iam_role.power_user.name
  policy_arn = aws_iam_policy.power_user_access.arn
}

resource "aws_iam_role" "read_only" {
  name               = "ReadOnly"
  assume_role_policy = jsonencode(local.engineer_assume_role_policy)
}

resource "aws_iam_role_policy_attachment" "allow_engineer_read_only_access" {
  role       = aws_iam_role.read_only.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
