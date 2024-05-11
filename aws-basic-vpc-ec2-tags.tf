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
