# Day 36

# First Step - Create VPC , and create Internet gateway and attach to VPC

resource "aws_vpc" "name" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

tags = local.vpc_final_tags
}