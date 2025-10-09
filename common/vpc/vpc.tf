resource "aws_vpc" "usw2dev" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "usw2dev"
  }
}

resource "aws_vpc" "usw2prd" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "usw2prd"
  }
}
