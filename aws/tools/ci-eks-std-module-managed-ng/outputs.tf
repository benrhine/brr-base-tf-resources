
output "vpc_id" {
  value = data.aws_vpc.custom.id
}

output "public_subnets" {
  value = data.aws_subnets.public.ids
}

output "private_subnets" {
  value = data.aws_subnets.private.ids
}

output "eks_cluster_name" {
  value = module.eks_cluster.cluster_name
}

output "eks_cluster_arn" {
  value = module.eks_cluster.cluster_arn
}

# output "eks_cluster_node_group_arn" {
#   value = aws_eks_node_group.eks_node_group.arn
# }

output "eks_role_name" {
  value = aws_iam_role.eks_role.name
}

output "eks_role_arn" {
  value = aws_iam_role.eks_role.arn
}

output "eks_ng_role_name" {
  value = aws_iam_role.eks_node_group_role.name
}

output "eks_ng_role_arn" {
  value = aws_iam_role.eks_node_group_role.arn
}

output "cluster_admin_role_001" {
  value = aws_eks_access_entry.eks_role_access.principal_arn
}

# output "cluster_admin_role_002" {
#   value = aws_eks_access_entry.oidc_role_access.principal_arn
# }

output "cluster_admin_role_003" {
  value = aws_eks_access_entry.sso_role_access.principal_arn
}

