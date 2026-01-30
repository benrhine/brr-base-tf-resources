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
# Create security groups
########################################################################################################################

# checkov:skip=CKV_AWS_23 "Ingress/egress rules intentionally managed at SG level"
# checkov:skip=CKV_AWS_382 "Node egress must be unrestricted for cluster operations"
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${local.resource_prefix}-eks-cluster-sg-${var.project_postfix}"
  description = "EKS cluster security group"
  vpc_id      = data.aws_vpc.custom.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name         = "${local.resource_prefix}-eks-cluster-sg-${var.project_postfix}"
    environment  = var.environment
    terraform    = "true"
    org          = var.org_name_abv
    team         = var.team_name
    create_date  = timestamp()
    cluster_name = "${local.resource_prefix}-eks-cluster-${var.project_postfix}" // Can not use reference as it causes a circular dependency
  }
}


# checkov:skip=CKV_AWS_23 "Ingress/egress rules intentionally managed at SG level"
# checkov:skip=CKV_AWS_382 "Node egress must be unrestricted for cluster operations"
resource "aws_security_group" "eks_node_sg" {
  name        = "${local.resource_prefix}-eks-node-sg-${var.project_postfix}"
  description = "EKS worker node security group"
  vpc_id      = data.aws_vpc.custom.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    security_groups = [
      aws_security_group.eks_cluster_sg.id
    ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    environment  = var.environment
    terraform    = "true"
    org          = var.org_name_abv
    team         = var.team_name
    create_date  = timestamp()
    cluster_name = "${local.resource_prefix}-eks-cluster-${var.project_postfix}" // Can not use reference as it causes a circular dependency
    name         = "${local.resource_prefix}-eks-node-sg-${var.project_postfix}"
  }
}

########################################################################################################################
# Create additional required? roles
########################################################################################################################
resource "aws_iam_role" "eks_role" {
  name = "${local.resource_prefix}-eks-role-${var.project_postfix}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::792981815698:role/aws-reserved/sso.amazonaws.com/us-east-2/AWSReservedSSO_AdministratorAccess_eeb8e63974797d2b"
        }
      }
    ]
  })
  tags = {
    environment  = var.environment
    terraform    = "true"
    org          = var.org_name_abv
    team         = var.team_name
    create_date  = timestamp()
    cluster_name = "${local.resource_prefix}-eks-cluster-${var.project_postfix}" // Can not use reference as it causes a circular dependency
    name         = "${local.resource_prefix}-eks-role-${var.project_postfix}"
  }
}

########################################################################################################################
# Role attachments These do not require tags as they are attaching pre-existing resources to a resource
########################################################################################################################
resource "aws_iam_role_policy_attachment" "eks_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

// Create custom policy to assign to role
// This is not a production ready policy but grants wide access for ease of testing
resource "aws_iam_policy" "policy" {
  name        = "eks-all-policy"
  description = "Provide all permissions for EKS"
  policy      = data.aws_iam_policy_document.eks_all_permissions.json
}

// Assign custom policy to role
resource "aws_iam_role_policy_attachment" "eks_custom_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = aws_iam_policy.policy.arn
}
// Without the above policy attached running the following ...
// aws --profile eks-role eks --region us-east-2 update-kubeconfig --name my-eks-cluster-example-1-trNUw3H4
// will fail with the following
# An error occurred (AccessDeniedException) when calling the DescribeCluster operation: User: arn:aws:sts::792981815698:assumed-role/eks-role/botocore-session-1768872094 is not authorized to perform: eks:DescribeCluster on resource: arn:aws:eks:us-east-2:792981815698:cluster/my-eks-cluster-example-1-trNUw3H4 because no identity-based policy allows the eks:DescribeCluster action

########################################################################################################################
# Create additional required? roles
########################################################################################################################
resource "aws_iam_role" "eks_node_group_role" {
  name = "${local.resource_prefix}-eks-ng-role-${var.project_postfix}"
  assume_role_policy = jsonencode({
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
    environment  = var.environment
    terraform    = "true"
    org          = var.org_name_abv
    team         = var.team_name
    create_date  = timestamp()
    cluster_name = "${local.resource_prefix}-eks-cluster-${var.project_postfix}" // Can not use reference as it causes a circular dependency
    name         = "${local.resource_prefix}-eks-ng-role-${var.project_postfix}"
  }
}

########################################################################################################################
# Role attachments: These do not require tags as they are attaching pre-existing resources to a resource
########################################################################################################################
resource "aws_iam_role_policy_attachment" "eks_node_group_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

########################################################################################################################
# Collect vpc ip's for Eks cluster
########################################################################################################################
locals {
  public_subnet_ids  = sort(data.aws_subnets.public.ids)
  private_subnet_ids = sort(data.aws_subnets.private.ids)
}

########################################################################################################################
# Create Eks cluster
########################################################################################################################
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${local.resource_prefix}-eks-cluster-${var.project_postfix}"
  role_arn = aws_iam_role.eks_role.arn
  vpc_config {
    subnet_ids         = local.private_subnet_ids
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }

  # Enable modern authentication mode
  access_config {
    authentication_mode = var.cluster_auth_mode
  }

  bootstrap_self_managed_addons = false

  # The "Easy Button"
  compute_config {
    enabled       = true
    node_pools    = ["general-purpose", "system"]
    node_role_arn = aws_iam_role.eks_node_group_role.arn
  }

  # Native Networking
  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  # Native Storage
  storage_config {
    block_storage {
      enabled = true
    }
  }

  lifecycle {
    precondition {
      condition     = length(local.private_subnet_ids) >= 2
      error_message = "EKS requires at least two subnets in different AZs"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_policy
  ]

  tags = {
    environment  = var.environment
    terraform    = "true"
    org          = var.org_name_abv
    team         = var.team_name
    create_date  = timestamp()
    cluster_name = "${local.resource_prefix}-eks-cluster-${var.project_postfix}" // Can not use reference as it causes a circular dependency
    name         = "${local.resource_prefix}-eks-cluster-${var.project_postfix}"
  }
}

resource "aws_eks_node_group" "bootstrap" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "bootstrap"
  node_role_arn  = aws_iam_role.eks_node_group_role.arn
  subnet_ids     = local.private_subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.small"]
  capacity_type  = "ON_DEMAND"

  labels = {
    role = "bootstrap"
  }

  taint {
    key    = "bootstrap-only"
    value  = "true"
    effect = "NO_SCHEDULE"
  }
}


resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "coredns"

  lifecycle {
    ignore_changes = all
  }
}


# resource "aws_iam_openid_connect_provider" "eks" {
#   url = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
#
#   client_id_list = ["sts.amazonaws.com"]
#
#   thumbprint_list = [
#     data.tls_certificate.eks.certificates[0].sha1_fingerprint
#   ]
# }
#
#
# resource "aws_iam_role" "ebs_csi" {
#   name = "${aws_eks_cluster.eks_cluster.name}-ebs-csi-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Federated = aws_iam_openid_connect_provider.eks.arn
#       }
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Condition = {
#         StringEquals = {
#           format(
#             "%s:sub",
#             replace(aws_iam_openid_connect_provider.eks.url, "https://", "")
#           ) = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
#         }
#       }
#     }]
#   })
# }
#
# resource "aws_iam_role_policy_attachment" "ebs_csi" {
#   role       = aws_iam_role.ebs_csi.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
# }
#
#
#
# resource "aws_eks_addon" "ebs_csi" {
#   cluster_name = aws_eks_cluster.eks_cluster.name
#   addon_name   = "aws-ebs-csi-driver"
#
#   service_account_role_arn = aws_iam_role.ebs_csi.arn
#
#   resolve_conflicts_on_create = "OVERWRITE"
# }


########################################################################################################################
# Create cluster access entries
# This configures the EKS role created as part of this Terraform to be a cluster admin. Additionally, this also configures
# your SSO user and the OIDC role used for this deployment as cluster administrators.
########################################################################################################################

# Validate that all roles are available and throw an explicit error if they are not
locals {
  eks_role_arn = try(
    aws_iam_role.eks_role.arn,
    throw("Required IAM role '${aws_iam_role.eks_role.name}' does not exist")
  )
  sso_role_arn = try(
    data.aws_iam_role.sso.arn,
    throw("Required IAM role '${var.requires_cluster_admin_role_001}' does not exist")
  )
  ci_role_arn = try(
    data.aws_iam_role.ci.arn,
    throw("Required IAM role '${var.requires_cluster_admin_role_002}' does not exist")
  )
}

resource "aws_eks_access_entry" "eks_role_access" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = local.eks_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "eks_role_access_policy" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = local.eks_role_arn

  access_scope {
    type = "cluster"
  }
  depends_on = [aws_iam_role.eks_role, aws_eks_cluster.eks_cluster]
}

resource "aws_eks_access_entry" "oidc_role_access" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = local.ci_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "oidc_role_access_policy" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = local.ci_role_arn

  access_scope {
    type = "cluster"
  }
  depends_on = [aws_iam_role.eks_role, aws_eks_cluster.eks_cluster]
}

resource "aws_eks_access_entry" "sso_role_access" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = local.sso_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "sso_role_access_policy" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = local.sso_role_arn

  access_scope {
    type = "cluster"
  }
  depends_on = [aws_iam_role.eks_role, aws_eks_cluster.eks_cluster]
}



