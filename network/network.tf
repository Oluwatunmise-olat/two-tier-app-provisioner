////////////////////////////////
///////////// VPC /////////////
///////////////////////////////
resource "aws_vpc" "two-tier-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "two-tier-vpc"
  }
}

////////////////////////////////
//////// Public Subnets ////////
///////////////////////////////
resource "aws_subnet" "two-tier-public-subnet-1" {
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.two-tier-vpc.id
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "two-tier-public-subnet-01"
  }
}

resource "aws_subnet" "two-tier-public-subnet-2" {
  cidr_block              = "10.0.2.0/24"
  vpc_id                  = aws_vpc.two-tier-vpc.id
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "two-tier-public-subnet-02"
  }
}


////////////////////////////////
/////// Private Subnets ///////
///////////////////////////////

resource "aws_subnet" "two-tier-private-subnet-1" {
  cidr_block              = "10.0.3.0/24"
  vpc_id                  = aws_vpc.two-tier-vpc.id
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false

  tags = {
    Name = "two-tier-private-subnet-01"
  }
}
resource "aws_subnet" "two-tier-private-subnet-2" {
  cidr_block              = "10.0.4.0/24"
  vpc_id                  = aws_vpc.two-tier-vpc.id
  availability_zone       = "us-east-1d"
  map_public_ip_on_launch = false
  tags = {
    Name = "two-tier-private-subnet-02"
  }
}

///////////////////////////////////////////////
/////// Public Subnet Internet Gateway ///////
/////////////////////////////////////////////
resource "aws_internet_gateway" "two-tier-igw" {
  vpc_id = aws_vpc.two-tier-vpc.id
  tags = {
    Name = "two-tier-igw"
  }
}

///////////////////////////////////////////
/////// Public Subnet Route Table ////////
/////////////////////////////////////////
resource "aws_route_table" "two-tier-rt" {
  vpc_id = aws_vpc.two-tier-vpc.id
  tags = {
    Name = "two-tier-rt"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.two-tier-igw.id
  }
}

///////////////////////////////////////////
/////// Private Subnet Route Table ////////
/////////////////////////////////////////
resource "aws_route_table" "two-tier-private-rt-01" {
  vpc_id = aws_vpc.two-tier-vpc.id
  tags = {
    Name = "two-tier-private-rt-01"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.private_gw_one.id
  }
}

resource "aws_route_table" "two-tier-private-rt-02" {
  vpc_id = aws_vpc.two-tier-vpc.id
  tags = {
    Name = "two-tier-private-rt-02"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.private_gw_two.id
  }
}

//////////////////////////////////////////////////////
/////// Public Subnet Route Table Association ////////
/////////////////////////////////////////////////////
resource "aws_route_table_association" "two-tier-rt-1" {
  subnet_id      = aws_subnet.two-tier-public-subnet-1.id
  route_table_id = aws_route_table.two-tier-rt.id
}
resource "aws_route_table_association" "two-tier-rt-2" {
  subnet_id      = aws_subnet.two-tier-public-subnet-2.id
  route_table_id = aws_route_table.two-tier-rt.id
}

//////////////////////////////////////////////////////
/////// Private Subnet Route Table Association ////////
/////////////////////////////////////////////////////

resource "aws_route_table_association" "two-tier-rt-3-pri" {
  subnet_id      = aws_subnet.two-tier-private-subnet-1.id
  route_table_id = aws_route_table.two-tier-private-rt-01.id
}
resource "aws_route_table_association" "two-tier-rt-4-priv" {
  subnet_id      = aws_subnet.two-tier-private-subnet-2.id
  route_table_id = aws_route_table.two-tier-private-rt-02.id
}


///////////////////////////////////////////
/////// Private Subnet Nat Gateway ///////
/////////////////////////////////////////
# terraform import aws_nat_gateway.private_gw_one nat-0732eccca2280d2c2
# terraform import module.network.aws_nat_gateway.private_gw_one nat-0732eccca2280d2c2
# This was provisioned maunally
resource "aws_nat_gateway" "private_gw_one" {
  subnet_id         = aws_subnet.two-tier-private-subnet-1.id
  connectivity_type = "private"

  tags = {
    "Name" = "proj-private-subnet-01"
  }
}

# terraform import module.network.aws_nat_gateway.private_gw_two nat-09882c3067d10e15c
resource "aws_nat_gateway" "private_gw_two" {
  subnet_id         = aws_subnet.two-tier-private-subnet-2.id
  connectivity_type = "private"

  tags = {
    "Name" = "proj-private-subnet-02"
  }
}

//////////////////////////////////
/////// Db Security Group ///////
////////////////////////////////
resource "aws_security_group" "db-sg" {
  name        = "private-db-sg"
  description = "Allow  only specific inbound traffic to db"
  vpc_id      = aws_vpc.two-tier-vpc.id

  # Allow traffic from ip address(instances) associated to web app security group
  ingress {
    from_port       = "0"
    to_port         = "3306"
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.web-sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "db-sg"
  }
}


//////////////////////////////////
/////// Web Security Group //////
////////////////////////////////
resource "aws_security_group" "web-sg" {
  name        = "public-web-sg"
  description = "Allow inbound traffic to web app"
  vpc_id      = aws_vpc.two-tier-vpc.id

  ingress {
    from_port   = "0"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "0"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

//////////////////////////////////
/////// Db Subnet Group //////
////////////////////////////////
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "two-tier-db-subnet-group"
  subnet_ids = [aws_subnet.two-tier-private-subnet-1.id, aws_subnet.two-tier-private-subnet-2.id]
}



# TODO:::
# Nat gatway
# Private route table
# Route table association with subnet