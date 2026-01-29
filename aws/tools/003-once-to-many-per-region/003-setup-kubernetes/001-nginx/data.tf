data "aws_region" "current" {}

data "aws_availability_zones" "available" {}


data "aws_eks_cluster" "eks_cluster" {
  name = "my-eks-cluster-example-1-uJ2G6bFh"
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = "my-eks-cluster-example-1-uJ2G6bFh"
}

# -----------------------------
# Detect GitHub OIDC Role ARN dynamically
# -----------------------------
data "aws_caller_identity" "ci" {}

# This is the IAM Role that GitHub Actions assumes
# Kubernetes only sees the assumed-role ARN, but we can build it dynamically
locals {
  github_oidc_arn = "arn:aws:sts::${data.aws_caller_identity.ci.account_id}:assumed-role/github_oidc_ci_assume_role/*"
}