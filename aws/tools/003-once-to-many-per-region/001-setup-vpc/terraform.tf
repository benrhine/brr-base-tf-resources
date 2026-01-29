
terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.27.0"
    }
  }
  required_version = "~> 1.14.3"

  # backend "s3" {
  #   bucket                  = "tf-state-cwn52hk6"
  #   key                     = "ci-vpc/terraform.tfstate"
  #   region                  = "us-west-2"
  #   encrypt                 = true
  #   use_lockfile            = true
  #   # profile                 = "brr-tools-admin"
  # }
}