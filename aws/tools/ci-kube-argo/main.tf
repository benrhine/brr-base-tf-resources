
resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}


resource "kubernetes_deployment" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace_v1.argocd.metadata[0].name
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
          image = "argoproj/argocd:v2.9.12" # latest stable version, adjust if needed

          port {
            container_port = 8080
          }

          # Optional: expose health checks
          liveness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace_v1.argocd.metadata[0].name
  }

  spec {
    selector = {
      app = kubernetes_deployment.argocd_server.spec[0].template[0].metadata[0].labels.app
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}