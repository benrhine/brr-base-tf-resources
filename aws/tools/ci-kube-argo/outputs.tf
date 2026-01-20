

# output "argocd_initial_admin_password" {
#   value = base64decode(
#     data.kubernetes_secret.argocd_admin.data["password"]
#   )
#   sensitive = true
# }

output "argocd_initial_admin_password" {
  value = try(
    base64decode(data.kubernetes_secret.argocd_admin.data["password"]),
    null
  )
  sensitive = true
}


output "argocd_server_address" {
  value = (
    length(data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress) > 0
    ? (
  try(
    data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname,
    data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].ip
  )
  )
    : "NodePort service – use kubectl port-forward"
  )
}

output "eks_connect_command" {
  value = "aws eks update-kubeconfig --region us-east-2 --name ${data.aws_eks_cluster.eks_cluster.name}"
}