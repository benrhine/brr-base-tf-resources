resource "aws_security_group" "eks_cluster_sg" {
  name        = "my-eks-cluster-eks-cluster-sg"
  description = "EKS cluster security group"
  vpc_id      = data.aws_vpc.custom.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "my-eks-cluster-eks-cluster-sg-example-1-${random_string.suffix.result}"
  }
}

resource "aws_security_group" "eks_node_sg" {
  name        = "my-eks-cluster-eks-node-sg"
  description = "EKS worker node security group"
  vpc_id      = data.aws_vpc.custom.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
    Name = "my-eks-cluster-eks-node-sg-example-1-${random_string.suffix.result}"
  }
}

#IAM Roles/Policies - All of the following are related to IAM Role and Policies
resource "aws_iam_role" "eks_role" {
  name = "eks-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-role"
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
}

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

locals {
  public_subnet_ids  = sort(data.aws_subnets.public.ids)
  private_subnet_ids = sort(data.aws_subnets.private.ids)
}

#EKS Cluster and Node Group deployment
resource "aws_eks_cluster" "eks_cluster" {
  name     = "my-eks-cluster-example-1-${random_string.suffix.result}"
  role_arn = aws_iam_role.eks_role.arn
  vpc_config {
    subnet_ids = local.private_subnet_ids
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }

  # Enable modern authentication mode
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  lifecycle {
    precondition {
      condition     = length(local.private_subnet_ids) >= 2
      error_message = "EKS requires at least two subnets in different AZs"
    }
  }

  depends_on = [aws_iam_role_policy_attachment.eks_policy]
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "my-node-group-example-1-${random_string.suffix.result}"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = local.private_subnet_ids
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.small"]
  remote_access {
    ec2_ssh_key = "brr-test"  # Replace with your key pair name
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_group_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_policy
  ]

}

//------
#####################################################################################
# Uses module to instantiate EKS
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

data "aws_eks_cluster" "eks_cluster" {
  depends_on = [
    aws_eks_cluster.eks_cluster
    # module.eks
  ]
  name = aws_eks_cluster.eks_cluster.name
  # name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "eks_cluster" {
  depends_on = [
    aws_eks_cluster.eks_cluster
    # module.eks
  ]
  name = aws_eks_cluster.eks_cluster.name
  # name = module.eks.cluster_name
}

# Define your SSO roles that need cluster admin access
locals {
  sso_roles = [
    {
      rolearn  = "arn:aws:iam::792981815698:role/AWSReservedSSO_AdministratorAccess_eeb8e63974797d2b"
      username = "brrAwsIdentity"
    },
    # Add more SSO roles here as needed
    # {
    #   rolearn  = "arn:aws:iam::<account-id>:role/AWSReservedSSO_AnotherRole"
    #   username = "anotherUser"
    # }
  ]

  # Base cluster admin role
  base_roles = [
    {
      rolearn  = "arn:aws:iam::792981815698:role/eks-cluster-admin-role"
      username = "admin"
    }
  ]

  all_roles = concat(local.base_roles, local.sso_roles)
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = join("\n", [
      for role in local.all_roles : <<EOF
- rolearn: ${role.rolearn}
  username: ${role.username}
  groups:
    - system:masters
EOF
    ])
  }
}

//-----

# resource "kubernetes_namespace" "terraform-nginx" {
#   metadata {
#     name = "nginx"
#   }
# }
#
#
# resource "kubernetes_deployment" "nginx" {
#   metadata {
#     name      = "nginx"
#     namespace = kubernetes_namespace.terraform-nginx.metadata[0].name
#   }
#
#   spec {
#     replicas = 1
#
#     selector {
#       match_labels = {
#         app = "nginx"
#       }
#     }
#
#     template {
#       metadata {
#         labels = {
#           app = "nginx"
#         }
#       }
#
#       spec {
#         container {
#           name  = "nginx"
#           image = "nginx:1.21.6"
#
#           port {
#             container_port = 80
#           }
#         }
#       }
#     }
#   }
# }
#
# resource "kubernetes_service" "nginx" {
#   metadata {
#     name      = "nginx"
#     namespace = kubernetes_namespace.terraform-nginx.metadata[0].name
#   }
#
#   spec {
#     selector = {
#       app = kubernetes_deployment.nginx.spec[0].template[0].metadata[0].labels.app
#     }
#
#     port {
#       port        = 80
#       target_port = 80
#     }
#
#     type = "LoadBalancer"
#   }
# }