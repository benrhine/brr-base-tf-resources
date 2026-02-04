data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

# THIS IS A PALCE I SHOULD SET THIS TO PULL DETAILS FROM OTHER TFSTATES
data "aws_eks_cluster" "eks_cluster" {
  # name = "${local.resource_prefix}-eks-cluster-${var.project_postfix}"
  name = "ci_eks_cluster-001-eks-cluster-${var.project_postfix}"
}

data "aws_eks_cluster_auth" "eks_cluster" {
  # name = "${local.resource_prefix}-eks-cluster-${var.project_postfix}"
  name = "ci_eks_cluster-001-eks-cluster-${var.project_postfix}"
}

# data "terraform_remote_state" "eks" {
#   backend = "s3"
#
#   config = {
#     bucket = "tf-state-xi7egjwf"
#     key    = "ci-eks-cluster/terraform.tfstate"
#     region = "us-east-2"
#   }
# }

data "kubernetes_secret" "argocd_admin" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }

  depends_on = [helm_release.argocd]
}

data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = helm_release.argocd.namespace
  }
  depends_on = [helm_release.argocd]
}
