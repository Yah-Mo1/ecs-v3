# Terraform configuration for VPC

# Get the available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az_names = data.aws_availability_zones.available.names
  nat_count = var.environment == "dev" ? 1 : length(local.az_names)
}

# Create the VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-vpc"
  })
}

# Create the public subnets
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  count             = length(local.az_names)
  availability_zone = local.az_names[count.index]
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  tags = merge(var.tags, {
    Name = "${var.project_name}-public-subnet-${local.az_names[count.index]}"
  })
}

# Create the private subnets
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  count             = length(local.az_names)
  availability_zone = local.az_names[count.index]
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index + length(local.az_names))
  tags = merge(var.tags, {
    Name = "${var.project_name}-private-subnet-${local.az_names[count.index]}"
  })
}

# Create the internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {
    Name = "${var.project_name}-igw"
  })
}

# One public route table. Every public subnet uses the same default route.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-public-rt"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = length(local.az_names)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count  = local.nat_count
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.project_name}-nat-eip-${local.az_names[count.index]}"
  })

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count         = local.nat_count
  subnet_id     = aws_subnet.public[count.index].id
  allocation_id = aws_eip.nat[count.index].id

  tags = merge(var.tags, {
    Name = "${var.project_name}-nat-${local.az_names[count.index]}"
  })
}

resource "aws_route_table" "private" {
  count  = local.nat_count
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-private-rt-${local.az_names[count.index]}"
  })
}

resource "aws_route" "private_nat" {
  count                  = local.nat_count
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

resource "aws_route_table_association" "private" {
  count     = length(local.az_names)
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[min(count.index, local.nat_count - 1)].id
}
