
########################################################################################################################
# Create security groups
########################################################################################################################

# checkov:skip=CKV_AWS_23 "Ingress/egress rules intentionally managed at SG level"
# checkov:skip=CKV_AWS_382 "Node egress must be unrestricted for cluster operations"
resource "aws_security_group" "eks_cluster_sg" {
  name                    = "${local.resource_prefix}-eks-cluster-sg-${var.project_postfix}"
  description             = "EKS cluster security group"
  vpc_id                  = data.aws_vpc.custom.id
  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }
  tags = {
    name                  = "${local.resource_prefix}-eks-cluster-sg-${var.project_postfix}"
    environment           = var.environment
    terraform             = "true"
    org                   = var.org_name_abv
    team                  = var.team_name
    create_date           = timestamp()
    cluster_name          = "${local.resource_prefix}-eks-cluster-${var.project_postfix}" // Can not use reference as it causes a circular dependency
  }
}


# checkov:skip=CKV_AWS_23 "Ingress/egress rules intentionally managed at SG level"
# checkov:skip=CKV_AWS_382 "Node egress must be unrestricted for cluster operations"
resource "aws_security_group" "eks_node_sg" {
  name                    = "${local.resource_prefix}-eks-node-sg-${var.project_postfix}"
  description             = "EKS worker node security group"
  vpc_id                  = data.aws_vpc.custom.id
  ingress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    security_groups = [
      aws_security_group.eks_cluster_sg.id
    ]
  }
  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }
  tags = {
    environment           = var.environment
    terraform             = "true"
    org                   = var.org_name_abv
    team                  = var.team_name
    create_date           = timestamp()
    cluster_name          = "${local.resource_prefix}-eks-cluster-${var.project_postfix}" // Can not use reference as it causes a circular dependency
    name                  = "${local.resource_prefix}-eks-node-sg-${var.project_postfix}"
  }
}

########################################################################################################################
# Create additional required? roles
########################################################################################################################
resource "aws_iam_role" "eks_role" {
  name                    = "${local.resource_prefix}-eks-role-${var.project_postfix}"
  assume_role_policy      = jsonencode({
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
    environment           = var.environment
    terraform             = "true"
    org                   = var.org_name_abv
    team                  = var.team_name
    create_date           = timestamp()
    cluster_name          = "${local.resource_prefix}-eks-cluster-${var.project_postfix}" // Can not use reference as it causes a circular dependency
    name                  = "${local.resource_prefix}-eks-role-${var.project_postfix}"
  }
}

########################################################################################################################
# Role attachments These do not require tags as they are attaching pre-existing resources to a resource
########################################################################################################################
resource "aws_iam_role_policy_attachment" "eks_policy" {
  role                    = aws_iam_role.eks_role.name
  policy_arn              = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

// Create custom policy to assign to role
// This is not a production ready policy but grants wide access for ease of testing
resource "aws_iam_policy" "policy" {
  name                    = "eks-all-policy-${random_string.suffix.result}"
  description             = "Provide all permissions for EKS"
  policy                  = data.aws_iam_policy_document.eks_all_permissions.json
}

// Assign custom policy to role
resource "aws_iam_role_policy_attachment" "eks_custom_policy" {
  role                    = aws_iam_role.eks_role.name
  policy_arn              = aws_iam_policy.policy.arn
}
// Without the above policy attached running the following ...
// aws --profile eks-role eks --region us-east-2 update-kubeconfig --name my-eks-cluster-example-1-trNUw3H4
// will fail with the following
# An error occurred (AccessDeniedException) when calling the DescribeCluster operation: User: arn:aws:sts::792981815698:assumed-role/eks-role/botocore-session-1768872094 is not authorized to perform: eks:DescribeCluster on resource: arn:aws:eks:us-east-2:792981815698:cluster/my-eks-cluster-example-1-trNUw3H4 because no identity-based policy allows the eks:DescribeCluster action

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

# https://github.com/terraform-aws-modules/terraform-aws-eks
module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.15.1"

  name               = "${local.resource_prefix}-eks-cluster-${var.project_postfix}"
  kubernetes_version = "1.34"

  # Enable modern authentication mode
  authentication_mode   = var.cluster_auth_mode

  # addons = {
  #   coredns                = {}
  #   eks-pod-identity-agent = {
  #     before_compute = true
  #   }
  #   kube-proxy             = {}
  #   vpc-cni                = {
  #     before_compute = true
  #   }
  # }

  # Optional
  endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  vpc_id     = "vpc-060fad6d748d9b3af"
  subnet_ids = local.private_subnet_ids

  tags = {
    environment           = var.environment
    terraform             = "true"
    org                   = var.org_name_abv
    team                  = var.team_name
    create_date           = timestamp()
    cluster_name          = "${local.resource_prefix}-eks-cluster-${var.project_postfix}" // Can not use reference as it causes a circular dependency
    name                  = "${local.resource_prefix}-eks-cluster-${var.project_postfix}"
  }
}

# module "eks_auto_custom_node_pools" {
#   source = "../.."
#
#   name                   = "${local.name}-custom"
#   kubernetes_version     = local.kubernetes_version
#   endpoint_public_access = true
#
#   enable_cluster_creator_admin_permissions = true
#
#   # Create just the IAM resources for EKS Auto Mode for use with custom node pools
#   create_auto_mode_iam_resources = true
#   compute_config = {
#     enabled = true
#   }
#
#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnets
#
#   tags = local.tags
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
    throw("Required IAM role '${local.cluster_admin_sso}' does not exist")
  )
  ci_role_arn = try(
    data.aws_iam_role.ci.arn,
    throw("Required IAM role '${local.cluster_admin_ci}' does not exist")
  )
}

resource "aws_eks_access_entry" "eks_role_access" {
  cluster_name            = module.eks_cluster.cluster_name
  principal_arn           = local.eks_role_arn
  type                    = "STANDARD"
}

resource "aws_eks_access_policy_association" "eks_role_access_policy" {
  cluster_name            = module.eks_cluster.cluster_name
  policy_arn              = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn           = local.eks_role_arn

  access_scope {
    type                  = "cluster"
  }
  depends_on = [aws_iam_role.eks_role, module.eks_cluster]
}

# resource "aws_eks_access_entry" "oidc_role_access" {
#   cluster_name            = module.eks_cluster.cluster_name
#   principal_arn           = local.ci_role_arn
#   type                    = "STANDARD"
# }
#
# resource "aws_eks_access_policy_association" "oidc_role_access_policy" {
#   cluster_name            = module.eks_cluster.cluster_name
#   policy_arn              = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
#   principal_arn           = local.ci_role_arn
#
#   access_scope {
#     type                  = "cluster"
#   }
#   depends_on = [aws_iam_role.eks_role, module.eks_cluster]
# }

resource "aws_eks_access_entry" "sso_role_access" {
  cluster_name            = module.eks_cluster.cluster_name
  principal_arn           = local.sso_role_arn
  type                    = "STANDARD"
}

resource "aws_eks_access_policy_association" "sso_role_access_policy" {
  cluster_name            = module.eks_cluster.cluster_name
  policy_arn              = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn           = local.sso_role_arn

  access_scope {
    type                  = "cluster"
  }
  depends_on = [aws_iam_role.eks_role, module.eks_cluster]
}


#####################################################################################
# Attempt 2
#####################################################################################
# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "~> 21.11"
#
#   name    = "example-2-${random_string.suffix.result}"
#   kubernetes_version = "1.34"
#
#   iam_role_arn = aws_iam_role.eks_role.arn
#
#   # Optional
#   endpoint_public_access = true
#
#   # Optional: Adds the current caller identity as an administrator via cluster access entry
#   enable_cluster_creator_admin_permissions = true
#
#   addons = {
#     coredns                = {}
#     eks-pod-identity-agent = {}
#     kube-proxy             = {}
#     vpc-cni                = {}
#   }
#
#   vpc_id     = data.aws_vpc.custom.id
#   subnet_ids = local.private_subnet_ids
#
#   eks_managed_node_groups = {
#     example = {
#       instance_types = ["t3.small"]
#       min_size       = 1
#       max_size       = 2
#       desired_size   = 1
#       subnet_ids      = local.private_subnet_ids
#       vpc_security_group_ids = [aws_security_group.eks_cluster_sg.id]
#       iam_role_arn = aws_iam_role.eks_node_group_role.arn
#       # remote_access = {
#       #   ec2_ssh_key = "brr-test"  # Replace with your key pair name
#       # }
#     }
#   }
#
#   access_entries = {
#     # One access entry with a policy associated
#     example = {
#       kubernetes_groups = []
#       principal_arn     = aws_iam_role.eks_role.arn
#
#       policy_associations = {
#         example = {
#           policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
#           access_scope = {
#             namespaces = ["default"]
#             type       = "namespace"
#           }
#         }
#       }
#     }
#   }
#
#   tags = {
#     environment = "dev"
#     terraform   = "true"
#   }
# }


