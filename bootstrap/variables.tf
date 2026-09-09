variable "environment" {
  type        = string
  description = "The name of this environment. This name should be unique among all environments in use"
}

variable "engineer_usernames" {
  type        = list(string)
  description = "A list of usernames (part of cabinet office digital email before the @) to grant engineer access to"
}

variable "base_user_account_id" {
  type        = string
  description = "The account ID of the base AWS account where engineer IAM users reside"
}

variable "engineer_allowed_ip_ranges" {
  type        = list(string)
  description = "The list of IP ranges to allow engineers to assume roles from"
}
