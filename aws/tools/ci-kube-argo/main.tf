########################################################################################################################
# Should resource names be prefixed with their environment? This is an interesting question around environment design.
# Do you want a cluster per environment? e.g. dev-cluster, test-cluster ... or do you want something more like a cluster
# per account where the cluster in the dev account may hold both dev and test deployments, the cluster in non-prod may
# hold the uat and regression deployments.
########################################################################################################################
locals {
  resource_prefix = var.environment_prefix ? "${var.environment}-${var.project_name}-${var.project_id}" : "${var.project_name}-${var.project_id}"
}

resource "kubernetes_namespace" "terraform_argocd" {
  metadata {
    name = "argocd"
  }
}

# resource "kubernetes_deployment" "argocd_server" {
#   metadata {
#     name      = "argocd-server"
#     namespace = kubernetes_namespace.terraform_argocd.metadata[0].name
#     labels = {
#       app = "argocd-server"
#     }
#   }
#
#   spec {
#     replicas = 1
#
#     selector {
#       match_labels = {
#         app = "argocd-server"
#       }
#     }
#
#     template {
#       metadata {
#         labels = {
#           app = "argocd-server"
#         }
#       }
#
#       spec {
#         container {
#           name  = "argocd-server"
#           image = "quay.io/argoproj/argocd:v2.9.3"
#
#           args = [
#             "argocd-server",
#             "--insecure"
#           ]
#
#           port {
#             container_port = 8080
#           }
#
#           readiness_probe {
#             http_get {
#               path = "/healthz"
#               port = 8080
#             }
#             initial_delay_seconds = 10
#             period_seconds        = 10
#           }
#
#           liveness_probe {
#             http_get {
#               path = "/healthz"
#               port = 8080
#             }
#             initial_delay_seconds = 30
#             period_seconds        = 20
#           }
#         }
#       }
#     }
#   }
# }
#
#
# resource "kubernetes_service" "argocd_server" {
#   metadata {
#     name      = "argocd-server"
#     namespace = kubernetes_namespace.terraform_argocd.metadata[0].name
#   }
#
#   spec {
#     selector = {
#       app = "argocd-server"
#     }
#
#     port {
#       name        = "http"
#       port        = 80
#       target_port = 8080
#     }
#
#     type = "NodePort"
#   }
# }

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
