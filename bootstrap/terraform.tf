terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.63.0"
    }
  }

  required_version = "~> 1.16.1"

  backend "local" {}
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Environment     = var.environment
      EnvironmentType = var.environment_type
      Component       = "bootstrap"
      Product         = "GOV.UK Licensing"
      Owner           = "made-tech-licensify@digital.cabinet-office.gov.uk"
      Source          = "https://github.com/alphagov/licensing-infrastructure"
    }
  }
}
