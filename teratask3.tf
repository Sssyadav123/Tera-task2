provider "aws" {
  region     = "ap-south-1"
  profile    = "sumit"
}

resource "aws_vpc" "Teratask3_vpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Teratask3_vpc"
  }
}

resource "aws_subnet" "mypublic-subnet" {
  vpc_id     = aws_vpc.Teratask3_vpc.id
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "mypublic-subnet"
  }
}

resource "aws_subnet" "myprivate-subnet" {
  vpc_id     = aws_vpc.Teratask3_vpc.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "myprivate-subnet"
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.Teratask3_vpc.id

  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "my-igwrt" {
  vpc_id = aws_vpc.Teratask3_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

 

  tags = {
    Name = "my-igwrt"
  }
}

resource "aws_route_table_association" "rtassociation" {
  subnet_id      = aws_subnet.mypublic-subnet.id
  route_table_id = aws_route_table.my-igwrt.id
}

resource "aws_security_group" "my-sg" {
  name        = "mysg"
  description = "Allow HTTP, SSH and ICMP"
  vpc_id      = aws_vpc.Teratask3_vpc.id
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "icmp"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "mysql"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-sg"
  }
}


resource "aws_instance" "wordpress-os" {
  ami           = "ami-052c08d70def0ac62"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.mypublic-subnet.id
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  key_name = "mykey111222"

  tags = {
    Name = "wordpress-os"
  }

}

resource "aws_security_group" "my-sg2" {
  name        = "my-sg2"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.Teratask3_vpc.id


  ingress {
    description = "mysql"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "my-sg2"
  }
}

resource "aws_instance" "mysql-os" {
  ami           = "ami-08706cb5f68222d09"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my-sg2.id]
  key_name = "mykey111222"
  subnet_id = aws_subnet.myprivate-subnet.id
  
  tags = {
    Name = "mysql"
  }
}

