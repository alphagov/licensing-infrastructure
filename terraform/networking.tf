### VPC-wide resources

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-${local.environment_name}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-${local.environment_name}"
  }
}

resource "aws_eip" "nat_gw" {
  for_each = toset(var.availability_zones)
  domain   = "vpc"

  tags = {
    Name = "nat-gw-${local.environment_name}-${each.value}"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  vpc_id            = aws_vpc.main.id
  availability_mode = "regional"
  connectivity_type = "public"

  dynamic "availability_zone_address" {
    for_each = toset(var.availability_zones)
    iterator = zone
    content {
      allocation_ids    = [aws_eip.nat_gw[zone.key].id]
      availability_zone = zone.value
    }
  }

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "nat-gw-${local.environment_name}"
  }
}

### Public subnets

resource "aws_subnet" "public" {
  for_each = toset(var.availability_zones)
  vpc_id   = aws_vpc.main.id

  # Public subnets are 10.0.0.0/24, 10.0.1.0/24 etc.
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, index(var.availability_zones, each.value))
  availability_zone       = each.value
  map_public_ip_on_launch = true

  tags = {
    Name = "public-${local.environment_name}-${each.value}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-${local.environment_name}"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

### Private subnets

resource "aws_subnet" "private" {
  for_each = toset(var.availability_zones)
  vpc_id   = aws_vpc.main.id

  # Public subnets are 10.0.10.0/24, 10.0.11.0/24 etc.
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, index(var.availability_zones, each.value) + 10)
  availability_zone = each.value

  tags = {
    Name = "private-${local.environment_name}-${each.value}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private-${local.environment_name}"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
