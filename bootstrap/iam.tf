resource "aws_iam_role" "admin" {
  for_each = toset(var.engineer_usernames)
  name     = "${each.value}-admin"
  assume_role_policy = jsonencode({
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
          AWS = ["arn:aws:iam::${var.base_user_account_id}:user/${each.value}@digital.cabinet-office.gov.uk"]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "allow_admin" {
  for_each   = aws_iam_role.admin
  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "power_user" {
  for_each = toset(var.engineer_usernames)
  name     = "${each.value}-power-user"
  assume_role_policy = jsonencode({
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
          AWS = ["arn:aws:iam::${var.base_user_account_id}:user/${each.value}@digital.cabinet-office.gov.uk"]
        }
      }
    ]
  })
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
  for_each   = aws_iam_role.power_user
  role       = each.value.name
  policy_arn = aws_iam_policy.power_user_access.arn
}

resource "aws_iam_role" "read_only" {
  for_each = toset(var.engineer_usernames)
  name     = "${each.value}-readonly"
  assume_role_policy = jsonencode({
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
          AWS = ["arn:aws:iam::${var.base_user_account_id}:user/${each.value}@digital.cabinet-office.gov.uk"]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "allow_engineer_read_only_access" {
  for_each   = aws_iam_role.read_only
  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
