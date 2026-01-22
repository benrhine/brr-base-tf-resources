########################################################################################################################
# Should resource names be prefixed with their environment? This is an interesting question around environment design.
# Do you want a cluster per environment? e.g. dev-cluster, test-cluster ... or do you want something more like a cluster
# per account where the cluster in the dev account may hold both dev and test deployments, the cluster in non-prod may
# hold the uat and regression deployments.
########################################################################################################################
locals {
  resource_prefix = var.environment_prefix ? "${var.environment}-${var.project_name}-${var.project_id}" : "${var.project_name}-${var.project_id}"
}

# checkov:skip=CKV2_AWS_11 "VPC flow logs will be enabled later"
# checkov:skip=CKV2_AWS_12 "Default security group restrictions handled externally"
resource "aws_vpc" "vpc" {
  cidr_block              = var.vpc_cidr_block
  tags = {
    name                  = "${local.resource_prefix}-vpc-${var.project_postfix}"
    environment           = var.environment
    terraform             = "true"
    org                   = var.org_name_abv
    team                  = var.team_name
    create_date           = timestamp()
    retrieval             = "test-retrieval"
  }
}
#####################################################################################

# checkov:skip=CKV_AWS_130 "This subnet is intentionally public for EKS load balancers"
resource "aws_subnet" "public_eks_subnet" {
  count 	              = 2
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element([var.vpc_public_subnet_01, var.vpc_public_subnet_02], count.index)
  # availability_zone = element(["us-east-2a", "us-east-2b"], count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true
  tags = {
    name                  = "${local.resource_prefix}-vpc-public-subnet-${var.project_postfix}"
    environment           = var.environment
    terraform             = "true"
    org                   = var.org_name_abv
    team                  = var.team_name
    create_date           = timestamp()
    retrieval             = "test-retrieval-public"
  }
}

# checkov:skip=CKV_AWS_130 "This subnet is intentionally public for EKS load balancers"
resource "aws_subnet" "private_eks_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element([var.vpc_private_subnet_01, var.vpc_private_subnet_02], count.index)
  # availability_zone = element(["us-east-2a", "us-east-2b"], count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true
  tags = {
    name                  = "${local.resource_prefix}-vpc-private-subnet-${var.project_postfix}"
    environment           = var.environment
    terraform             = "true"
    org                   = var.org_name_abv
    team                  = var.team_name
    create_date           = timestamp()
    retrieval             = "test-retrieval-private"
  }
}

#####################################################################################
# Same in both examples
#####################################################################################
resource "aws_internet_gateway" "igw" {
  vpc_id                  = aws_vpc.vpc.id

  tags = {
    name                  = "${local.resource_prefix}-vpc-ig-${var.project_postfix}"
    environment           = var.environment
    terraform             = "true"
    org                   = var.org_name_abv
    team                  = var.team_name
    create_date           = timestamp()
  }
}

resource "aws_route_table" "public" {
  vpc_id                  = aws_vpc.vpc.id
  route {
    cidr_block            = var.vpc_public_route_table
    gateway_id            = aws_internet_gateway.igw.id
  }
  tags = {
    name                  = "${local.resource_prefix}-vpc-public-rt-${var.project_postfix}"
    environment           = var.environment
    terraform             = "true"
    org                   = var.org_name_abv
    team                  = var.team_name
    create_date           = timestamp()
  }
}
#####################################################################################

resource "aws_route_table" "private" {
  count                   = 2
  vpc_id                  = aws_vpc.vpc.id
  route {
    cidr_block            = var.vpc_private_route_table
    gateway_id            = aws_internet_gateway.igw.id
  }
  tags = {
    name                  = "${local.resource_prefix}-vpc-private-rt-${var.project_postfix}"
    environment           = var.environment
    terraform             = "true"
    org                   = var.org_name_abv
    team                  = var.team_name
    create_date           = timestamp()
  }
}

resource "aws_route_table_association" "public" {
  count                   = 2
  subnet_id               = element(aws_subnet.public_eks_subnet[*].id, count.index)
  route_table_id          = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count                   = 2
  subnet_id               = element(aws_subnet.private_eks_subnet[*].id, count.index)
  route_table_id          = aws_route_table.private[count.index].id
}