terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_subnet" "aws_subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.aws_subnet1.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "all" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere (not recommended for production)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from anywhere
  }


  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# resource "aws_s3_bucket" "s3_bucket" {
#   bucket = "harshit-s3-bucket"
# }

resource "aws_instance" "my-instance" {
  ami                         = var.ami_name
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.aws_subnet1.id
  vpc_security_group_ids      = [aws_security_group.all.id]
  key_name = var.key_name
  associate_public_ip_address = true
  user_data = file("temp.sh")

  root_block_device {
        volume_size = 10
    }

  
}

output "my_instance_public_ip" {
  value = aws_instance.my-instance.public_ip
}
