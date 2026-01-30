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
  name = local.cluster_admin_sso
}

data "aws_iam_role" "ci" {
  name = local.cluster_admin_ci
}