provider "aws" {
  region     = "ap-south-1"
  profile    = "sumit"
}

resource "aws_vpc" "Tetatask2_vpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Tetatask2_vpc"
  }
}

resource "aws_subnet" "Terraformsubnet1" {
  vpc_id     = "${aws_vpc.Tetatask2_vpc.id}"
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Terraformsubnet1"
  }
}

resource "aws_subnet" "Terraformsubnet2-1b" {
  vpc_id     = "${aws_vpc.Tetatask2_vpc.id}"
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "Terraformsubnet2-1b"
  }
}

resource "aws_internet_gateway" "Terraform_internet_gw" {
  vpc_id = "${aws_vpc.Tetatask2_vpc.id}"

  tags = {
    Name = "Terraform_internet_gw"
  }
}

resource "aws_route_table" "my_table" {
  vpc_id = "${aws_vpc.Tetatask2_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.Terraform_internet_gw.id}"
  }

 

  tags = {
    Name = "my_table"
  }
}

resource "aws_route_table_association" "rta_Terraformsubnet2-1b" {
  subnet_id      = "${aws_subnet.Terraformsubnet2-1b.id}"
  route_table_id = "${aws_route_table.my_table.id}"
}

resource "aws_security_group" "my_security_gp" {
  name        = "my_security"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.Tetatask2_vpc.id}"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks =  ["0.0.0.0/0"]
  }
  

  tags = {
    Name = "my_security_gp"
  }
}

resource "aws_instance" "wordpress-os" {
  ami           = "ami-052c08d70def0ac62"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.Terraformsubnet2-1b.id}"
  vpc_security_group_ids = ["${aws_security_group.my_security_gp.id}"]
  key_name = "mykey111222"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "wordpress-os"
  }

}

resource "aws_instance" "mysql-os" {
  ami           = "ami-0eb64c49a2299a148"
  instance_type = "t2.micro"
  
  subnet_id = "${aws_subnet.Terraformsubnet1.id}"
  vpc_security_group_ids = ["${aws_security_group.my_security_gp.id}"]
  key_name = "mykey111222"
  availability_zone = "ap-south-1a"

 tags = {
    Name = "mysql-os"
  }

}
