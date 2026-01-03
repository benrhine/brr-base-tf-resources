
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "${var.project_name}-${var.project_id}-${random_string.suffix.result}"
    org = var.org_name_abv
    team = var.team_name
    # create_date = "XXX"
  }
}
#####################################################################################

resource "aws_subnet" "public_eks_subnet" {
  count 	    = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(["10.0.1.0/24", "10.0.2.0/24"], count.index)
  # availability_zone = element(["us-east-2a", "us-east-2b"], count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true
  tags = {
    name = "${var.project_name}-${var.project_id}-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private_eks_subnet" {
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(["10.0.3.0/24", "10.0.4.0/24"], count.index)
  # availability_zone = element(["us-east-2a", "us-east-2b"], count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true
  tags = {
    name = "${var.project_name}-${var.project_id}-private-subnet-${count.index}"
  }
}

#####################################################################################
# Same in both examples
#####################################################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    name = "${var.project_name}-${var.project_id}-ig-${random_string.suffix.result}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    name = "${var.project_name}-${var.project_id}-rt-public-${random_string.suffix.result}"
  }
}
#####################################################################################

resource "aws_route_table" "private" {
  count             = 2
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    name = "${var.project_name}-${var.project_id}-rt-private-${random_string.suffix.result}"
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