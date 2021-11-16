provider "aws" {
  region = "${var.region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

resource "aws_vpc" "cloudknowledgevpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "cloudknowledgevpc"
  }
}

resource "aws_subnet" "public-subnet-1" {
  vpc_id     = aws_vpc.cloudknowledgevpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone_id = "use2-az1"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.cloudknowledgevpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id     = aws_vpc.cloudknowledgevpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone_id = "use2-az2"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_security_group" "cloudknowledgesg" {
  name        = "cloudknowledge"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.cloudknowledgevpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloudknowledgesg"
  }
}

resource "aws_internet_gateway" "cloudknowledge-igw" {
  vpc_id = aws_vpc.cloudknowledgevpc.id

  tags = {
    Name = "cloudknowledge=igw"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.cloudknowledgevpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudknowledge-igw.id
  }

  tags = {
    Name = "public-rt"
  }
}
resource "aws_route_table_association" "punlic-asso1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "punlic-asso2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public-rt.id
}





resource "aws_eip" "cloudknowledge-natip" {
  vpc      = true
}

resource "aws_nat_gateway" "clouknowlege-nat" {
  allocation_id = aws_eip.cloudknowledge-natip.id
  subnet_id         = aws_subnet.public-subnet-1.id
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.cloudknowledgevpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.clouknowlege-nat.id
  }

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "priviate-asso" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}


