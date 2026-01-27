
# THESE CALLS ARE PULLING THE DATA FROM THE LOCALLY LOGGED IN ACCOUNT - I.E. IF YOU ARE LOGGED INTO US-WEST-2 IT WILL
# RETURN US-WEST-2

# Retrieve the current aws account
data "aws_caller_identity" "current" {}

# Retrieve the current aws region
data "aws_region" "current" {}
########################################################################################################################
# Find previously created VPC
########################################################################################################################
data "aws_vpc" "custom" {
  filter {
    name   = "tag:retrieval"
    values = ["test-retrieval"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.custom.id]
  }

  filter {
    name   = "tag:retrieval"
    values = ["test-retrieval-public"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.custom.id]
  }

  filter {
    name   = "tag:retrieval"
    values = ["test-retrieval-private"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}


data "aws_iam_policy_document" "eks_all_permissions" {
  statement {
    actions = [
      "eks:*"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

########################################################################################################################
# Find additional IAM roles that require Kubernetes access
########################################################################################################################

data "aws_iam_role" "sso" {
  name = var.requires_cluster_admin_role_001
}

data "aws_iam_role" "ci" {
  name = var.requires_cluster_admin_role_002
}

data "aws_eks_cluster" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.name

  # depends_on = [aws_eks_cluster.eks_cluster]
}
#
# data "aws_eks_cluster_auth" "eks_cluster" {
#   name = aws_eks_cluster.eks_cluster.name
#
#   # depends_on = [aws_eks_cluster.eks_cluster]
# }

data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

