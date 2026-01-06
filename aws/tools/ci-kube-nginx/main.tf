
resource "kubernetes_namespace_v1" "terraform-argocd" {
  metadata {
    name = "argocd"
  }
}


resource "kubernetes_deployment" "argocd" {
  metadata {
    name      = "argocd"
    namespace = kubernetes_namespace_v1.terraform-argocd.metadata[0].name
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
          image = "argocd:1.21.6"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name      = "argocd"
    namespace = kubernetes_namespace_v1.terraform-argocd.metadata[0].name
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