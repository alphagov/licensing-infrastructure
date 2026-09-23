locals {
  environment_name = var.environment_type == "development" ? terraform.workspace : var.environment_type
}
