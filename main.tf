# Day 36

# First Step - To Create VPC , and create Internet gateway and attach to VPC

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = local.vpc_final_tags
}

# create internet gateway and map to VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # VPC association
  tags   = local.igw_final_tags
}

# Create two Public subnets in 2 AZ , us-east-1a and us-east-1b
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    # roboshop-dev-public-us-east-1a
    {
      Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
    },
    var.public_subnet_tags
  )
}


# Create two private subnets in 2 AZ , us-east-1a and us-east-1b
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
        local.common_tags,
        # roboshop-dev-private-us-east-1a
        {
            Name = "${var.project}-${var.environment}-private-${local.az_names[count.index]}"
        },
        var.private_subnet_tags
    )
}


# Create two DB subnets in 2 AZ , us-east-1a and us-east-1b
resource "aws_subnet" "database" {
  count             = length(var.database_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  # map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    # roboshop-dev-database-us-east-1a
    {
      Name = "${var.project}-${var.environment}-database-${local.az_names[count.index]}"
    },
    var.database_subnet_tags
  )
}


# public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    # roboshop-dev-public
    {
      Name = "${var.project}-${var.environment}-public"
    },
    var.public_route_table_tags
  )
}


# private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    # roboshop-dev-public
    {
      Name = "${var.project}-${var.environment}-private"
    },
    var.private_route_table_tags
  )
}


# database route table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    # roboshop-dev-public
    {
      Name = "${var.project}-${var.environment}-database"
    },
    var.database_route_table_tags
  )
}

# create route in public route table via internet gateway
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id

}

# create elastic ip for NAT gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = merge(
    local.common_tags,
    # roboshop-dev-nat
    {
      Name = "${var.project}-${var.environment}-nat"
    },
    var.eip_tags
  )
}


# create NAT gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id  # creating this only in us-east-1a AZ

  tags = merge(
    local.common_tags,
    # roboshop-dev-nat
    {
      Name = "${var.project}-${var.environment}"
    },
    var.nat_gateway_tags
  )

  depends_on = [ aws_internet_gateway.main ]
}


# create route in private route table via NAT gateway
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id

}


# create route in database route table via NAT gateway
resource "aws_route" "database" {
  route_table_id         = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id

}

# associate route table in both public subnets
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# associate route table in both private subnets
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


# associate route table in both database subnets
resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}