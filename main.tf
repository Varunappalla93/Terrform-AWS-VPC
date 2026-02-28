# Day 36

# First Step - Create VPC , and create Internet gateway and attach to VPC

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = local.vpc_final_tags
}


resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # VPC association
  tags   = local.igw_final_tags
}

# Public subnet
resource "aws_subnet" "public" {
  count=length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  
}
