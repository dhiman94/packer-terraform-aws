# Declare AZ data source 
data "aws_availability_zones" "azs" {
  state = "available"
}

# create vpc 
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}

# create public subnets in all azs
resource "aws_subnet" "public_subnet" {
  count                   = length(local.az_names)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet-${count.index + 1}"
  }
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public_subnet : subnet.id]
}

# create 3 private subnets
resource "aws_subnet" "private_subnet" {
  count                   = length(slice(local.az_names, 0, 3))
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + length(local.az_names))
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "PrivateSubnet-${count.index + 1}"
  }
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private_subnet : subnet.id]
}

locals {
  az_names = data.aws_availability_zones.azs.names
}

# create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "IGW"
  }
}

# create public subnet route table
resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public RT"
  }
}

# create private subnet route table
resource "aws_route_table" "private_subnet_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Private RT"
  }
}

# associate public subnet RT
resource "aws_route_table_association" "public_subnet_rt_assoc" {
  count          = length(local.az_names) 
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_subnet_route_table.id
}

# associate private subnet RT
resource "aws_route_table_association" "private_subnet_rt_assoc" {
  count          = 3
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_subnet_route_table.id
}


