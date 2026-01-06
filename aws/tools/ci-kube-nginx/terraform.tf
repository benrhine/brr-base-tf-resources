
terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.27.0"
    }
  }
  required_version = "~> 1.14.3"

  backend "s3" {
    bucket                  = "tf-state-w9mdifvw"
    key                     = "ci-kube-nginx/terraform.tfstate"
    region                  = "us-east-2"
    encrypt                 = true
    use_lockfile            = true
    # profile                 = "brr-tools-admin"
  }
}