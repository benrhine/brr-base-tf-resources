data "aws_region" "current" {}

data "aws_availability_zones" "available" {}


data "aws_eks_cluster" "eks_cluster" {
  name = "my-eks-cluster-example-1-lZnlDXgh"
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = "my-eks-cluster-example-1-lZnlDXgh"
}

data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "tf-state-xi7egjwf"
    key    = "ci-eks-cluster/terraform.tfstate"
    region = "us-east-2"
  }
}