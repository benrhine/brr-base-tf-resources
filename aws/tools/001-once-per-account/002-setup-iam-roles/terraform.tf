
terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.27.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.9.0"
    }
  }
  required_version = "~> 1.14.3"

  # backend "s3" {
  #   bucket                  = "tf-state-xk89z7f9"
  #   key                     = "account-resources/terraform.tfstate"
  #   region                  = "us-east-2"
  #   encrypt                 = true
  #   use_lockfile            = true
  #   # profile                 = "brr-tools-admin"
  # }
}