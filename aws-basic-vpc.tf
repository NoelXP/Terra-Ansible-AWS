#Define Terraform Providers and Backend
terraform {
  required_version = "> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

#Default provider: AWS
provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
  region                   = "us-east-2"
}

# VPC
resource "aws_vpc" "taa-vpc" {
  cidr_block = "172.21.0.0/19" #172.21.0.0 - 172.21.31.254
  tags = {
    Name = "taa-vpc"
  }
}

# Subnet
resource "aws_subnet" "taa-public-sub-00" {
  vpc_id                  = aws_vpc.taa-vpc.id
  cidr_block              = "172.21.0.0/23" #172.21.0.0 - 172.21.1.255
  map_public_ip_on_launch = true
  tags = {
    Name = "taa-public-sub-00"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "taa-ig" {
  vpc_id = aws_vpc.taa-vpc.id
  tags = {
    Name = "taa-ig"
  }
}

# routing table for public subnet (access to the internt)
resource "aws_route_table" "taa-rt-pub-main" {
  vpc_id = aws_vpc.taa-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.taa-ig.id
  }

  tags = {
    Name = "taa-rt-pib-main"
  }
}

# Set new main_route_table as main
resource "aws_main_route_table_association" "taa-rta-default" {
  vpc_id         = aws_vpc.taa-vpc.id
  route_table_id = aws_route_table.taa-rt-pub-main.id
}

#Create a "base" security group to be assigned to all EC2 instances
resource "aws_security_group" "taa-sg-base-ec2" {
  name   = "taa-sg-ssh-ec2"
  vpc_id = aws_vpc.taa-vpc.id
}

#DANGEROUS!!
#Allow access from the Internet to port 22 (SSH) in the EC2 instances
resource "aws_security_group_rule" "taa-sr-internet-to-ec2-ssh" {
  security_group_id = aws_security_group.taa-sg-base-ec2.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # Internet
}

# Allow access from the internet for ICMP protocol (e.g. ping) to the EC2 instances
resource "aws_security_group_rule" "taa-sr-internet-to-ec2-icmp" {
  security_group_id = aws_security_group.taa-sg-base-ec2.id
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"] # Internet
}

# Allow all outbound traffic to the internet
resource "aws_security_group_rule" "taa-sr-all-outbound" {
  security_group_id = aws_security_group.taa-sg-base-ec2.id
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Create a security group for the Front end Server
resource "aws_security_group" "taa-sg-front-end" {
  name   = "taa-sg-front-end"
  vpc_id = aws_vpc.taa-vpc.id
}

# Allow access from the Internet to port 80 in the ec2 instances
resource "aws_security_group_rule" "taa-sr-internet-to-front-end-80" {
  security_group_id = aws_security_group.taa-sg-front-end.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # Internet
}

# Create a security group for the Back end Server
resource "aws_security_group" "taa-sg-back-end" {
  name   = "taa-sg-back-end"
  vpc_id = aws_vpc.taa-vpc.id
}

# Allow access from the front-end to the port 3306 in the backend (MariaDB)
resource "aws_security_group_rule" "taa-sr-front-end-to-mariadb" {
  security_group_id        = aws_security_group.taa-sg-back-end.id
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.taa-sg-front-end.id
}