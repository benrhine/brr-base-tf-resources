
terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28.0"
    }
  }
  required_version = "~> 1.14.3"

  backend "s3" {
    bucket                  = "tf-state-xi7egjwf"
    key                     = "003-ci-eks-std-irsa-module-managed-ng/terraform.tfstate"
    region                  = "us-east-2"
    encrypt                 = true
    use_lockfile            = true
    # profile                 = "brr-tools-admin"
  }
}