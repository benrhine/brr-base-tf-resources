data "aws_region" "current" {}

data "aws_availability_zones" "available" {}


data "aws_eks_cluster" "eks_cluster" {
  name = "my-eks-cluster-example-1-P8PcW3eK"
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = "my-eks-cluster-example-1-P8PcW3eK"
}