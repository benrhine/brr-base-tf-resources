
resource "kubernetes_namespace" "terraform_argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_deployment" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace.terraform_argocd.metadata[0].name
    labels = {
      app = "argocd-server"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "argocd-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "argocd-server"
        }
      }

      spec {
        container {
          name  = "argocd-server"
          image = "quay.io/argoproj/argocd:v2.9.3"

          args = [
            "argocd-server",
            "--insecure"
          ]

          port {
            container_port = 8080
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }
            initial_delay_seconds = 30
            period_seconds        = 20
          }
        }
      }
    }
  }
}


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
#     type = "LoadBalancer"
#   }
# }
