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
# Specific to pod identity
########################################################################################################################
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

########################################################################################################################
# Find additional IAM roles that require Kubernetes access
########################################################################################################################

data "aws_iam_role" "sso" {
  name = local.cluster_admin_sso
}

data "aws_iam_role" "ci" {
  name = local.cluster_admin_ci
}

data "aws_eks_cluster" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.name
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.name
}