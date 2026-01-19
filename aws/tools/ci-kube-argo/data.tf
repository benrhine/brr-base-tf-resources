data "aws_region" "current" {}

data "aws_availability_zones" "available" {}


data "aws_eks_cluster" "eks_cluster" {
  name = "my-eks-cluster-example-1-twc9rNT9"
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = "my-eks-cluster-example-1-twc9rNT9"
}