# Day 36 and 37

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "default" {
  default = false
}

data "aws_route_table" "default" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "association.main"
    values = ["true"]
  }
}                              
