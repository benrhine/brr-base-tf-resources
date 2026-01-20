
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
    actions   = [
      "eks:*"
    ]
    resources = ["*"]
    effect = "Allow"
  }
}

// find iam role

data "aws_iam_role" "sso" {
  name = "AWSReservedSSO_AdministratorAccess_eeb8e63974797d2b"
}

data "aws_iam_role" "ci" {
  name = "github_oidc_ci_assume_role"
}