resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.common.env}-${var.common.project}"
  }
}

# Create public subnets for each AZ within the regional VPC
resource "aws_subnet" "public" {
  for_each = var.subnet_az
 
  vpc_id = aws_vpc.vpc.id
  availability_zone = each.key
  map_public_ip_on_launch = true
 
  # 2,048 IP addresses each
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.value)

  tags = {
    Name = "${var.common.env}-${var.common.project}-public-subnet"
    Role = "public"
    Subnet = "${each.key}-${each.value}"
  }
}
 
# Create private subnets for each AZ within the regional VPC
resource "aws_subnet" "private" {
  for_each = var.subnet_az
 
  vpc_id = aws_vpc.vpc.id
  availability_zone = each.key
 
  # 2,048 IP addresses each
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.value + length(var.subnet_az))
 
  tags = {
    Name = "${var.common.env}-${var.common.project}-private-subnet"
    Role = "private"
    Subnet = "${each.key}-${each.value}"
  }
}
###
# IGW and NGW
##
resource "aws_internet_gateway" "igw" {
  
  vpc_id = aws_vpc.vpc.id
 
  tags = {
    Name = "${var.common.env}-${var.common.project}"
  }
}
 
resource "aws_eip" "nat" {
  count = var.enable_nat_gw ? length(var.subnet_az) : 0

  vpc = true

  lifecycle {
    # prevent_destroy = true
  }

  tags = {
    Name = "${var.common.env}-${var.common.project}-${count.index}"
    VPC  = aws_vpc.vpc.id
  }
}

resource "aws_nat_gateway" "ngw" {
  count = var.enable_nat_gw ? length(var.subnet_az) : 0

  allocation_id = aws_eip.nat[count.index].allocation_id

  subnet_id = aws_subnet.public[element(keys(aws_subnet.public), "${count.index}")].id

  tags = {
    Name = "${var.common.env}-${var.common.project}-${count.index}"
  }
}

###
# Route Tables, Routes and Associations
##

# Public Route Table (Subnets with IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.common.env}-${var.common.project}"
  }
}

# Private Route Tables (Subnets with NGW)
resource "aws_route_table" "private" {
  count = length(var.subnet_az)

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.common.env}-${var.common.project}-${count.index}"
  }
}

# Public Route
resource "aws_route" "public" {
  route_table_id  = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id      = aws_internet_gateway.igw.id
}

# Private Route
resource "aws_route" "private" {
  # count = length(var.subnet_az)
  count = var.enable_nat_gw ? length(var.subnet_az) : 0

  route_table_id  = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id  = aws_nat_gateway.ngw[count.index].id
}

# Public Route to Public Route Table for Public Subnets
resource "aws_route_table_association" "public" {
  for_each  = aws_subnet.public
  subnet_id = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

# Private Route to Private Route Table for Private Subnets
resource "aws_route_table_association" "private" {
  count = length(var.subnet_az)

  subnet_id = aws_subnet.private[element(keys(aws_subnet.private), "${count.index}")].id
  route_table_id = aws_route_table.private[count.index].id
}

# Accecc output 

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
}