
output "vpc_id" {
  value = data.aws_vpc.custom.id
}

output "public_subnets" {
  value = data.aws_subnets.public.ids
}

output "private_subnets" {
  value = data.aws_subnets.private.ids
}

output "eks_cluster_node_group_arn" {
  value = aws_eks_node_group.eks_node_group.arn
}

output "eks_ng_role_name" {
  value = aws_iam_role.eks_node_group_role.name
}

output "eks_ng_role_arn" {
  value = aws_iam_role.eks_node_group_role.arn
}


