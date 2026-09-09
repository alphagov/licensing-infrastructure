terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.63.0"
    }
  }

  required_version = "~> 1.16.1"
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Environment     = var.environment
      EnvironmentType = var.environment_type
      Stack           = "bootstrap"
      Application     = "GOV.UK Licensing"
    }
  }
}
