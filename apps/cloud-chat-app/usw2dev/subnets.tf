# Public Subnet for CCA
resource "aws_subnet" "cca_public_a" {
  vpc_id            = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.app_short_name}-pub-a"
    Type = "public"
  }
}

resource "aws_subnet" "cca_public_b" {
  vpc_id            = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "${var.app_short_name}-pub-a"
    Type = "public"
  }
}

# Private Subnet for CCA
resource "aws_subnet" "cca_private_a" {
  vpc_id            = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.app_short_name}-prv-a"
    Type = "private"
  }
}

resource "aws_subnet" "cca_private_b" {
  vpc_id            = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "${var.app_short_name}-prv-b"
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
    Name = "${var.app_short_name}-nat-eip"
  }

  depends_on = [aws_internet_gateway.cca_igw]
}

# NAT Gateway for private subnet
resource "aws_nat_gateway" "cca_nat_a" {
  allocation_id = aws_eip.cca_nat_eip.id
  subnet_id     = aws_subnet.cca_public_a.id

  tags = {
    Name = "${var.app_short_name}-nat"
  }

  depends_on = [aws_internet_gateway.cca_igw]
}

# Route table for public subnet
resource "aws_route_table" "cca_public_a_rt" {
  vpc_id = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cca_igw.id
  }

  tags = {
    Name = "${var.app_short_name}-pub-a-rt"
    Type = "public"
  }
}

resource "aws_route_table" "cca_public_b_rt" {
  vpc_id = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cca_igw.id
  }

  tags = {
    Name = "${var.app_short_name}-pub-b-rt"
    Type = "public"
  }
}

# Route table for private subnet
resource "aws_route_table" "cca_private_a_rt" {
  vpc_id = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.cca_nat_a.id
  }

  tags = {
    Name = "${var.app_short_name}-prv-a-rt"
    Type = "private"
  }
}

resource "aws_route_table" "cca_private_b_rt" {
  vpc_id = data.terraform_remote_state.vpc.outputs.usw2dev_vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.cca_nat_a.id
  }

  tags = {
    Name = "${var.app_short_name}-prv-b-rt"
    Type = "private"
  }
}

resource "aws_route_table_association" "cca_public_a_rta" {
  subnet_id      = aws_subnet.cca_public_a.id
  route_table_id = aws_route_table.cca_public_a_rt.id
}

resource "aws_route_table_association" "cca_private_a_rta" {
  subnet_id      = aws_subnet.cca_private_a.id
  route_table_id = aws_route_table.cca_private_a_rt.id
}

resource "aws_route_table_association" "cca_private_b_rta" {
  subnet_id      = aws_subnet.cca_private_b.id
  route_table_id = aws_route_table.cca_private_b_rt.id
}

resource "aws_route_table_association" "cca_public_b_rta" {
  subnet_id      = aws_subnet.cca_public_b.id
  route_table_id = aws_route_table.cca_public_b_rt.id
}
