########################################################################################################################
# Should resource names be prefixed with their environment? This is an interesting question around environment design.
# Do you want a cluster per environment? e.g. dev-cluster, test-cluster ... or do you want something more like a cluster
# per account where the cluster in the dev account may hold both dev and test deployments, the cluster in non-prod may
# hold the uat and regression deployments.
########################################################################################################################
locals {
  resource_prefix = var.environment_prefix ? "${var.environment}-${var.project_name}-${var.project_id}" : "${var.project_name}-${var.project_id}"
}

########################################################################################################################
# Create additional required? roles
########################################################################################################################
resource "aws_iam_role" "eks_node_group_role" {
  name                    = "${local.resource_prefix}-eks-ng-role-${var.project_postfix}"
  assume_role_policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    environment           = var.environment
    terraform             = "true"
    org                   = var.org_name_abv
    team                  = var.team_name
    create_date           = timestamp()
    cluster_name          = "${local.resource_prefix}-eks-cluster-${var.project_postfix}" // Can not use reference as it causes a circular dependency
    name                  = "${local.resource_prefix}-eks-ng-role-${var.project_postfix}"
  }
}

########################################################################################################################
# Role attachments: These do not require tags as they are attaching pre-existing resources to a resource
########################################################################################################################
resource "aws_iam_role_policy_attachment" "eks_node_group_policy" {
  role                    = aws_iam_role.eks_node_group_role.name
  policy_arn              = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role                    = aws_iam_role.eks_node_group_role.name
  policy_arn              = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
  role                    = aws_iam_role.eks_node_group_role.name
  policy_arn              = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

########################################################################################################################
# Collect vpc ip's for Eks cluster
########################################################################################################################
locals {
  public_subnet_ids       = sort(data.aws_subnets.public.ids)
  private_subnet_ids      = sort(data.aws_subnets.private.ids)
}

########################################################################################################################
# Create Eks Node Group
########################################################################################################################
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name            = data.aws_eks_cluster.eks_cluster.name
  node_group_name         = "${local.resource_prefix}-node-group-${var.project_postfix}"
  node_role_arn           = aws_iam_role.eks_node_group_role.arn
  subnet_ids              = local.private_subnet_ids
  scaling_config {
    desired_size          = var.cluster_ng_desired_size
    max_size              = var.cluster_ng_max_size
    min_size              = var.cluster_ng_min_size
  }

  instance_types          = ["t3.medium", "t3a.medium", "m5.large"]

  remote_access {
    ec2_ssh_key           = var.cluster_ng_remote_access_key  # Replace with your key pair name
  }

  update_config {
    max_unavailable       = var.cluster_ng_max_unavailable
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_group_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_policy
  ]

  tags = {
    environment           = var.environment
    terraform             = "true"
    org                   = var.org_name_abv
    team                  = var.team_name
    create_date           = timestamp()
    cluster_name          = "${local.resource_prefix}-eks-cluster-${var.project_postfix}" // Can not use reference as it causes a circular dependency
    name                  = "${local.resource_prefix}-node-group-${var.project_postfix}"
  }
}


