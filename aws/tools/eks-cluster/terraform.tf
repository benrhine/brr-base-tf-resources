# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.27.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      # version = "2.30.0"
      version = ">= 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1.1"
    }
  }
  required_version = "~> 1.14.3"

  backend "s3" {
    bucket                  = "tf-state-zvsso9t4"
    key                     = "eks-cluster/terraform.tfstate"
    region                  = "us-east-2"
    encrypt                 = true
    use_lockfile            = true
    # profile                 = "brr-tools-admin"
  }
}