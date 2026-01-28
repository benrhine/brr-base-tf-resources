
// Return the command to update the local kubectl - This will have the Aws region stared out in the GitHub workflow so insert
// the expected region
output "eks_connect_command" {
  value = "aws eks update-kubeconfig --region us-east-2 --name ${data.aws_eks_cluster.eks_cluster.name}"
}

// Command to get the initial admin password for ArgoCD
output "kubectl_get_argo_pass_command" {
  value = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"
}

// Default user for ArgoCD
output "argocd_initial_admin_user" {
  value = "admin"
}

// Get the default password for ArgoCd
output "argocd_initial_admin_password" {
  // Not sure how but Terraform apparently automatically is running base64decode on this value and is returning the
  // correct / expected value
  value = data.kubernetes_secret.argocd_admin.data["password"]    // Decoded value
  sensitive = true
}

// Return the Aws LoadBalancer address - This will have the Aws region stared out in the GitHub workflow so insert
// the expected region
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

output "server_address_reminder" {
  value = "REMEMBER YOU CAN NOT BE CONNECTED TO TAILSCALE OR A VPN IN ORDER FOR THE SERVER ADDRESS TO RESOLVE"
}