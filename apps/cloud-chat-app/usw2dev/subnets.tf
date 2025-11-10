# Public Subnet for CCA
resource "aws_subnet" "cca_public" {
  vpc_id                  = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_short_name}-public-${var.env_name}"
    Type = "public"
  }
}

# Private Subnet for CCA
resource "aws_subnet" "cca_private" {
  vpc_id            = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.app_short_name}-private-${var.env_name}"
    Type = "private"
  }
}

# Internet Gateway for the VPC
resource "aws_internet_gateway" "cca_igw" {
  vpc_id = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id

  tags = {
    Name = "${var.app_short_name}-igw-${var.env_name}"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "cca_nat_eip" {
  domain = "vpc"

  tags = {
    Name = "${var.app_short_name}-nat-eip-${var.env_name}"
  }

  depends_on = [aws_internet_gateway.cca_igw]
}

# NAT Gateway for private subnet
resource "aws_nat_gateway" "cca_nat" {
  allocation_id = aws_eip.cca_nat_eip.id
  subnet_id     = aws_subnet.cca_public.id

  tags = {
    Name = "${var.app_short_name}-nat-${var.env_name}"
  }

  depends_on = [aws_internet_gateway.cca_igw]
}

# Route table for public subnet
resource "aws_route_table" "cca_public_rt" {
  vpc_id = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cca_igw.id
  }

  tags = {
    Name = "${var.app_short_name}-public-rt-${var.env_name}"
    Type = "public"
  }
}

# Route table for private subnet
resource "aws_route_table" "cca_private_rt" {
  vpc_id = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.cca_nat.id
  }

  tags = {
    Name = "${var.app_short_name}-private-rt-${var.env_name}"
    Type = "private"
  }
}

resource "aws_route_table_association" "cca_public_rta" {
  subnet_id      = aws_subnet.cca_public.id
  route_table_id = aws_route_table.cca_public_rt.id
}

resource "aws_route_table_association" "cca_private_rta" {
  subnet_id      = aws_subnet.cca_private.id
  route_table_id = aws_route_table.cca_private_rt.id
}
