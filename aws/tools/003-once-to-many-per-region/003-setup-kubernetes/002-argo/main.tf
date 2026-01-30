
resource "kubernetes_namespace" "terraform_argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  # depends_on = [aws_eks_node_group.main]
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "9.3.4"

  timeout    = 900        # ← DO THIS
  wait       = true
  atomic     = true

  namespace = "argocd"

  create_namespace = true

  # skip_crds = true

  set = [
    {
      name  = "server.service.type"
      value = "LoadBalancer"
    },
    {
      name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
      value = "nlb"
    },
    {
      name  = "applicationset.enabled"
      value = "false"
    }
  ]
}
