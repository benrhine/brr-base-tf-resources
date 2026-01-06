
resource "kubernetes_cluster_role_binding" "github_actions_admin" {
  metadata {
    name = "github-actions-cluster-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind = "User"
    name = "arn:aws:sts::792981815698:assumed-role/github_oidc_ci_assume_role/20765437338-1"
  }
}

resource "kubernetes_namespace" "terraform-nginx" {
  metadata {
    name = "argocd"
  }
}


resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "argocd"
    namespace = kubernetes_namespace.terraform-nginx.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:1.21.6"

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
    name      = "nginx"
    namespace = kubernetes_namespace.terraform-nginx.metadata[0].name
  }

  spec {
    selector = {
      app = kubernetes_deployment.nginx.spec[0].template[0].metadata[0].labels.app
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}