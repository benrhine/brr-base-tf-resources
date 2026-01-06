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
  depends_on = [aws_iam_role_policy_attachment.eks_policy]

  lifecycle {
    precondition {
      condition     = length(local.private_subnet_ids) >= 2
      error_message = "EKS requires at least two subnets in different AZs"
    }
  }
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