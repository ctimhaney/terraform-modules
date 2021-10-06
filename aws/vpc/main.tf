provider "aws" {
  profile = "default"
  region  = var.aws_region
}

# Create a VPC with the provided CIDR
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.prefix} VPC"
  }
}

# Create an internet gateway our external subnets will use
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.prefix} IGW"
  }
}

# Create EIP for each external subnet, should we have any internal subnets
resource "aws_eip" "main" {
  count = length(var.internal_subnets) > 0 ? length(var.external_subnets) : 0
  vpc   = true
  tags = {
    Name = "${var.prefix} EIP ${count.index + 1}"
  }
}

# Create our internal subnets
resource "aws_subnet" "internal" {
  count             = length(var.internal_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.internal_subnets[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]
  tags = {
    Name = "${var.prefix} Internal Subnet ${count.index + 1}"
  }
}

# Create our external subnets
resource "aws_subnet" "external" {
  count             = length(var.external_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.external_subnets[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]
  tags = {
    Name = "${var.prefix} External Subnet ${count.index + 1}"
  }
}

# create a NAT gateway for each external subnet, should we have any internal subnets
resource "aws_nat_gateway" "main" {
  count         = length(var.internal_subnets) > 0 ? length(var.external_subnets) : 0
  allocation_id = aws_eip.main[count.index].id
  subnet_id     = aws_subnet.external[count.index].id
  tags = {
    Name = "${var.prefix} NAT Gateway ${count.index + 1}"
  }
}

# Create our NACL rules for external subnets
resource "aws_network_acl" "external" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [for i in aws_subnet.external : i.id]

  tags = {
    Name = "${var.prefix} External NACL"
  }
}

# rules for ingress into external subnets
resource "aws_network_acl_rule" "external_ingress" {
  count = length(var.external_nacl_ingress)

  network_acl_id = aws_network_acl.external.id
  rule_number    = format("10%3f", count.index)
  egress         = false
  protocol       = var.external_nacl_ingress[count.index].protocol
  rule_action    = "allow"
  cidr_block     = var.external_nacl_ingress[count.index].cidr_block
  from_port      = var.external_nacl_ingress[count.index].from_port
  to_port        = var.external_nacl_ingress[count.index].to_port
}

resource "aws_network_acl_rule" "external_egress" {
  count = length(var.external_nacl_egress)

  network_acl_id = aws_network_acl.external.id
  rule_number    = format("20%3f", count.index)
  egress         = true
  protocol       = var.external_nacl_egress[count.index].protocol
  rule_action    = "allow"
  cidr_block     = var.external_nacl_egress[count.index].cidr_block
  from_port      = var.external_nacl_egress[count.index].from_port
  to_port        = var.external_nacl_egress[count.index].to_port
}

# Create our NACL rules for internal subnets
resource "aws_network_acl" "internal" {
  count      = length(var.internal_subnets) > 0 ? 1 : 0
  vpc_id     = aws_vpc.main.id
  subnet_ids = [for i in aws_subnet.internal : i.id]

  tags = {
    Name = "${var.prefix} Internal NACL"
  }
}

resource "aws_network_acl_rule" "internal_ingress" {
  count = length(var.internal_nacl_ingress)

  network_acl_id = aws_network_acl.internal[0].id
  rule_number    = format("30%3f", count.index)
  egress         = false
  protocol       = var.internal_nacl_ingress[count.index].protocol
  rule_action    = "allow"
  cidr_block     = var.internal_nacl_ingress[count.index].cidr_block
  from_port      = var.internal_nacl_ingress[count.index].from_port
  to_port        = var.internal_nacl_ingress[count.index].to_port
}

resource "aws_network_acl_rule" "internal_egress" {
  count = length(var.internal_nacl_egress)

  network_acl_id = aws_network_acl.internal[0].id
  rule_number    = format("40%3f", count.index)
  egress         = true
  protocol       = var.internal_nacl_egress[count.index].protocol
  rule_action    = "allow"
  cidr_block     = var.internal_nacl_egress[count.index].cidr_block
  from_port      = var.internal_nacl_egress[count.index].from_port
  to_port        = var.internal_nacl_egress[count.index].to_port
}

# Create our route table for external subnets
resource "aws_route_table" "external" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.prefix} External Subnets Route Table"
  }
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.external.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associate our external route table with each of our external subnets
resource "aws_route_table_association" "external" {
  count          = length(aws_subnet.external)
  subnet_id      = aws_subnet.external[count.index].id
  route_table_id = aws_route_table.external.id
}

# Create route tables for each of our internal subnets
resource "aws_route_table" "internal" {
  count  = length(var.internal_subnets)
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.prefix} Internal Subnet ${count.index + 1} Route Table"
  }
}

resource "aws_route" "nat" {
  count          = length(var.internal_subnets)
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.internal[count.index].id
  nat_gateway_id = aws_nat_gateway.main[count.index % length(var.external_subnets)].id
}

# Associate each internal route table with its respective subnet
resource "aws_route_table_association" "internal" {
  count          = length(var.internal_subnets)
  subnet_id      = aws_subnet.internal[count.index].id
  route_table_id = aws_route_table.internal[count.index].id
}
