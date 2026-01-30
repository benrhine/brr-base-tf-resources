
terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.27.0"
    }
  }
  required_version = "~> 1.14.3"


  backend "s3" {
    bucket                  = "tf-state-xi7egjwf"
    key                     = "003-once-to-many-per-region/001-setup-vpc/us-east-2/terraform.tfstate"
    region                  = "us-east-2"
    encrypt                 = true
    use_lockfile            = true
    # profile                 = "brr-tools-admin"
  }
}