resource "aws_vpc" "key_cloak_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    "Name" = "keycloak-from-new-vpc/KeyCloak/Vpc"
  }
}

resource "aws_internet_gateway" "key_cloak_vpc_igw" {
  vpc_id = aws_vpc.key_cloak_vpc.id
  tags = {
    Name = "keycloak-from-new-vpc/KeyCloak/Vpc"
  }
}

resource "aws_internet_gateway_attachment" "key_cloak_vpc_igw_attachment" {
  vpc_id              = aws_vpc.key_cloak_vpc.id
  internet_gateway_id = aws_internet_gateway.key_cloak_vpc_igw.id
}

resource "aws_subnet" "key_cloak_vpc_public_subnet_1" {
  vpc_id                  = aws_vpc.key_cloak_vpc.id
  cidr_block              = var.public_subnet_1_cidr_block
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "keycloak-from-new-vpc/KeyCloak/Vpc/PublicSubnet1"
  }
  depends_on = [aws_internet_gateway_attachment.key_cloak_vpc_igw_attachment]
}

resource "aws_route_table" "key_cloak_vpc_public_subnet_1_route_table" {
  vpc_id = aws_vpc.key_cloak_vpc.id
  tags = {
    Name = "keycloak-from-new-vpc/KeyCloak/Vpc/PublicSubnet1"
  }
}

resource "aws_route_table_association" "key_cloak_vpc_public_subnet_1_route_table_association" {
  subnet_id      = aws_subnet.key_cloak_vpc_public_subnet_1.id
  route_table_id = aws_route_table.key_cloak_vpc_public_subnet_1_route_table.id
}

resource "aws_route" "key_cloak_vpc_public_subnet_1_default_route" {
  route_table_id         = aws_route_table.key_cloak_vpc_public_subnet_1_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.key_cloak_vpc_igw.id
}

resource "aws_eip" "key_cloak_vpc_public_subnet_1_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway_attachment.key_cloak_vpc_igw_attachment]
}

resource "aws_nat_gateway" "key_cloak_vpc_public_subnet_1_nat_gateway" {
  allocation_id = aws_eip.key_cloak_vpc_public_subnet_1_eip.id
  subnet_id     = aws_subnet.key_cloak_vpc_public_subnet_1.id

  tags = {
    Name = "keycloak-from-new-vpc/KeyCloak/Vpc/PublicSubnet1"
  }

  depends_on = [aws_internet_gateway_attachment.key_cloak_vpc_igw_attachment]
}

resource "aws_subnet" "key_cloak_vpc_public_subnet_2" {
  vpc_id                  = aws_vpc.key_cloak_vpc.id
  cidr_block              = var.public_subnet_2_cidr_block
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "keycloak-from-new-vpc/KeyCloak/Vpc/PublicSubnet2"
  }
  depends_on = [aws_internet_gateway_attachment.key_cloak_vpc_igw_attachment]
}

resource "aws_route_table" "key_cloak_vpc_public_subnet_2_route_table" {
  vpc_id = aws_vpc.key_cloak_vpc.id
  tags = {
    Name = "keycloak-from-new-vpc/KeyCloak/Vpc/PublicSubnet2"
  }
}

resource "aws_route_table_association" "key_cloak_vpc_public_subnet_2_route_table_association" {
  subnet_id      = aws_subnet.key_cloak_vpc_public_subnet_2.id
  route_table_id = aws_route_table.key_cloak_vpc_public_subnet_2_route_table.id
}

resource "aws_route" "key_cloak_vpc_public_subnet_2_default_route" {
  route_table_id         = aws_route_table.key_cloak_vpc_public_subnet_2_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.key_cloak_vpc_igw.id
}

resource "aws_subnet" "key_cloak_vpc_private_subnet_1" {
  vpc_id                  = aws_vpc.key_cloak_vpc.id
  cidr_block              = var.private_subnet_1_cidr_block
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "keycloak-from-new-vpc/KeyCloak/Vpc/PrivateSubnet1"
  }
  depends_on = [aws_internet_gateway_attachment.key_cloak_vpc_igw_attachment]
}

resource "aws_route_table" "key_cloak_vpc_private_subnet_1_route_table" {
  vpc_id = aws_vpc.key_cloak_vpc.id
  tags = {
    Name = "keycloak-from-new-vpc/KeyCloak/Vpc/PrivateSubnet1"
  }
}

resource "aws_route_table_association" "key_cloak_vpc_private_subnet_1_route_table_association" {
  subnet_id      = aws_subnet.key_cloak_vpc_private_subnet_1.id
  route_table_id = aws_route_table.key_cloak_vpc_private_subnet_1_route_table.id
}

resource "aws_route" "key_cloak_vpc_private_subnet_1_default_route" {
  route_table_id         = aws_route_table.key_cloak_vpc_private_subnet_1_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.key_cloak_vpc_public_subnet_1_nat_gateway.id
}

resource "aws_subnet" "key_cloak_vpc_private_subnet_2" {
  vpc_id                  = aws_vpc.key_cloak_vpc.id
  cidr_block              = var.private_subnet_2_cidr_block
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "keycloak-from-new-vpc/KeyCloak/Vpc/PrivateSubnet2"
  }
  depends_on = [aws_internet_gateway_attachment.key_cloak_vpc_igw_attachment]
}

resource "aws_route_table" "key_cloak_vpc_private_subnet_2_route_table" {
  vpc_id = aws_vpc.key_cloak_vpc.id
  tags = {
    Name = "keycloak-from-new-vpc/KeyCloak/Vpc/PrivateSubnet2"
  }
}

resource "aws_route_table_association" "key_cloak_vpc_private_subnet_2_route_table_association" {
  subnet_id      = aws_subnet.key_cloak_vpc_private_subnet_2.id
  route_table_id = aws_route_table.key_cloak_vpc_private_subnet_2_route_table.id
}

resource "aws_route" "key_cloak_vpc_private_subnet_2_default_route" {
  route_table_id         = aws_route_table.key_cloak_vpc_private_subnet_2_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.key_cloak_vpc_public_subnet_1_nat_gateway.id
}