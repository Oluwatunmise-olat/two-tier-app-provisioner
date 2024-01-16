output "vpc_id" {
  value = aws_vpc.two-tier-vpc.id
}

output "public_subnet_one_id" {
  value = aws_subnet.two-tier-public-subnet-1.id
}

output "public_subnet_two_id" {
  value = aws_subnet.two-tier-public-subnet-2.id
}

output "private_subnet_one_id" {
  value = aws_subnet.two-tier-private-subnet-1.id
}

output "private_subnet_two_id" {
  value = aws_subnet.two-tier-private-subnet-2.id
}

output "public_subnet_internet_gw_id" {
  value = aws_internet_gateway.two-tier-igw.id
}

output "public_subnet_route_table_id" {
  value = aws_route_table.two-tier-rt.id
}

output "web_sg_id" {
  value = aws_security_group.web-sg.id
}

output "db_sg_id" {
  value = aws_security_group.db-sg.id
}