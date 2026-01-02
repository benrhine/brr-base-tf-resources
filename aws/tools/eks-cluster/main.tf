
resource "random_string" "suffix" {
  length  = 8
  special = false
}
#####################################################################################

#####################################################################################
# Same in both examples
#####################################################################################
#Network (All of the following are related to AWS EKS Networking)
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "eks-vpc-example-1-${random_string.suffix.result}"
    org = var.business_area_name
    team = var.team_name
  }
}
#####################################################################################

resource "aws_subnet" "public_eks_subnet" {
  count 	    = 2
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = element(["10.0.1.0/24", "10.0.2.0/24"], count.index)
  # availability_zone = element(["us-east-2a", "us-east-2b"], count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true
  tags = {
    name = "eks-public-subnet-example-1-${count.index}"
  }
}

resource "aws_subnet" "private_eks_subnet" {
  count             = 2
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = element(["10.0.3.0/24", "10.0.4.0/24"], count.index)
  # availability_zone = element(["us-east-2a", "us-east-2b"], count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true
  tags = {
    name = "eks-private-subnet-example-1-${count.index}"
  }
}

#####################################################################################
# Same in both examples
#####################################################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    name = "my-eks-cluster-example-1-${random_string.suffix.result}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    name = "my-eks-cluster-example-1-public-${random_string.suffix.result}"
  }
}
#####################################################################################

resource "aws_route_table" "private" {
  count             = 2
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    name = "my-eks-cluster-example-1-private-${random_string.suffix.result}"
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = element(aws_subnet.public_eks_subnet[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.private_eks_subnet[*].id, count.index)
  route_table_id = aws_route_table.private[count.index].id
}

#####################################################################################
# Manually Configure EKS
#####################################################################################
resource "aws_security_group" "eks_cluster_sg" {
  name        = "my-eks-cluster-eks-cluster-sg"
  description = "EKS cluster security group"
  vpc_id      = aws_vpc.eks_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "my-eks-cluster-eks-cluster-sg-example-1-${random_string.suffix.result}"
  }
}

resource "aws_security_group" "eks_node_sg" {
  name        = "my-eks-cluster-eks-node-sg"
  description = "EKS worker node security group"
  vpc_id      = aws_vpc.eks_vpc.id
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
    name = "my-eks-cluster-eks-node-sg-example-1-${random_string.suffix.result}"
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

#EKS Cluster and Node Group deployment
resource "aws_eks_cluster" "eks_cluster" {
  name     = "my-eks-cluster-example-1-${random_string.suffix.result}"
  role_arn = aws_iam_role.eks_role.arn
  vpc_config {
    subnet_ids = aws_subnet.private_eks_subnet[*].id
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }
  depends_on = [aws_iam_role_policy_attachment.eks_policy]
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "my-node-group-example-1-${random_string.suffix.result}"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = aws_subnet.private_eks_subnet[*].id
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

#Kubernetes resources in Terraform
resource "kubernetes_namespace" "terraform-argocd" {
  metadata {
    name = "argocod"
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "5.51.6"

  values = [
    # file("${path.module}/argocd-values.yaml")
    yamlencode({
      server = {
        extraArgs = ["--insecure"]
        service = {
          type = "LoadBalancer"
        }
        ingress = {
          enabled = true
          hosts   = ["argocd.example.com"]
          tls     = []
        }
      }
      dex = {
        enabled = true
      }
      notifications = {
        enabled = true
      }
      ha = {
        enabled = true
      }
    })
  ]
}

# resource "kubernetes_deployment" "argocd" {
#   metadata {
#     name      = "argocd"
#     namespace = kubernetes_namespace.terraform-argocd.metadata[0].name
#   }
#
#   spec {
#     replicas = 1
#
#     selector {
#       match_labels = {
#         app = "argocd"
#       }
#     }
#
#     template {
#       metadata {
#         labels = {
#           app = "argocd"
#         }
#       }
#
#       spec {
#         container {
#           name  = "argocd"
#           image = "argocd:1.21.6"
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
# resource "kubernetes_service" "argocd" {
#   metadata {
#     name      = "argocd"
#     namespace = kubernetes_namespace.terraform-argocd.metadata[0].name
#   }
#
#   spec {
#     selector = {
#       app = kubernetes_deployment.argocd.spec[0].template[0].metadata[0].labels.app
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