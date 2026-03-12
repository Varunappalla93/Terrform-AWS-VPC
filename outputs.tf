# Day 36 and 37 and 38 and 39

output "azs_info" {
    value = data.aws_availability_zones.available
}

# module should output the reqd vpc id info to users, users should catch and store in SSM parameter store
output "vpc_id" {
    value = aws_vpc.main.id
}

output "public_subnet_ids" {
    value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
    value = aws_subnet.private[*].id
}

output "database_subnet_ids" {
    value = aws_subnet.database[*].id
}