
resource "kubernetes_namespace" "terraform_argocd" {
  metadata {
    name = "argocd"
  }
}


resource "kubernetes_deployment" "argocd" {
  metadata {
    name      = "argocd"
    namespace = kubernetes_namespace.terraform_argocd.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "argocd"
      }
    }

    template {
      metadata {
        labels = {
          app = "argocd"
        }
      }

      spec {
        container {
          name  = "argocd"
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

resource "kubernetes_service" "argocd" {
  metadata {
    name      = "argocd"
    namespace = kubernetes_namespace.terraform_argocd.metadata[0].name
  }

  spec {
    selector = {
      app = kubernetes_deployment.argocd.spec[0].template[0].metadata[0].labels.app
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}