

output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

#Output Load Balancer IP to access from browser
# output "nginx_load_balancer_ip" {
#   value = kubernetes_service.nginx.status[0].load_balancer[0].ingress[0].ip
# }
#
# output "nginx_load_balancer_hostname" {
#   value = kubernetes_service.nginx.status[0].load_balancer[0].ingress[0].hostname
# }

output "eks_connect" {
  value = "aws --profile brr-np-admin eks --region ${data.aws_region.current.name} update-kubeconfig --name ${aws_eks_cluster.eks_cluster.name}"
}