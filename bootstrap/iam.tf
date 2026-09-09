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

resource "aws_iam_role" "full_access" {
  name               = "FullAccess"
  assume_role_policy = jsonencode(local.engineer_assume_role_policy)
}

resource "aws_iam_role_policy_attachment" "allow_full_access" {
  role       = aws_iam_role.full_access.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "read_only" {
  name               = "ReadOnly"
  assume_role_policy = jsonencode(local.engineer_assume_role_policy)
}

resource "aws_iam_role_policy_attachment" "allow_engineer_read_only_access" {
  role       = aws_iam_role.read_only.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
