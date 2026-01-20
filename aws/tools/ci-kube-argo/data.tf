data "aws_region" "current" {}

data "aws_availability_zones" "available" {}


data "aws_eks_cluster" "eks_cluster" {
  name = "my-eks-cluster-example-1-lZnIDXgh"
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = "my-eks-cluster-example-1-lZnIDXgh"
}

data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "tf-state-xi7egjwf"
    key    = "ci-eks-cluster/terraform.tfstate"
    region = "us-east-2"
  }
}

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
    namespace = "argocd"
  }

  depends_on = [helm_release.argocd]
}