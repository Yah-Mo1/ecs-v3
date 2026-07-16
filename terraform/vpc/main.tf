# Terraform configuration for VPC

locals {
  project_name = var.project_name

  tags = {
    environment = var.environment
    region = var.region
  }

}

# Get the available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Create the VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = merge(local.tags, {
    Name = "${var.project_name}-vpc"
  })
}

# Create the public subnets
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  count = data.aws_availability_zones.available.count
  cidr_block = var.public_subnet_cidr_block
  tags = merge(local.tags, {
    Name = "${var.project_name}-public-subnet"
  })
}   

# Create the private subnets
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  count = data.aws_availability_zones.available.count
  cidr_block = var.private_subnet_cidr_block
  tags = merge(local.tags, {
    Name = "${var.project_name}-private-subnet"
  })
}

# Create the internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.tags, {
    Name = "${var.project_name}-internet-gateway"
  })
}

# Create the public route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  count = data.aws_availability_zones.available.count
  tags = merge(local.tags, {
    Name = "${var.project_name}-public-route-table"
  })
}

# Associate the public subnets with the public route tables
resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
  count = data.aws_availability_zones.available.count
}



# Create the Elastic IP for the NAT gateways
resource "aws_eip" "nat" {
  domain = "vpc"
  count = data.aws_availability_zones.available.count
  tags = merge(local.tags, {
    Name = "${var.project_name}-nat-eip"
  })
}

# Create the NAT gateways -- For now we are using Nat gateways - later we will use vpc endpoints
resource "aws_nat_gateway" "main" {
  subnet_id = aws_subnet.public[count.index].id
  count = data.aws_availability_zones.available.count
  allocation_id = aws_eip.nat[count.index].id
  tags = merge(local.tags, {
    Name = "${var.project_name}-nat-gateway"
  })
}

# Create the private route tables
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  count = data.aws_availability_zones.available.count
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }
  tags = merge(local.tags, {
    Name = "${var.project_name}-private-route-table"
  })
}

# Associate the private subnets with the private route tables
resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
  count = data.aws_availability_zones.available.count
}