#Define Terraform Providers and Backend
terraform {
    required_version = "> 1.5"
    
    required_providers {
        aws = {
            source = "hashicorp/aws"
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
    cidr_block = 172.21.0.0/19 #172.21.0.0 - 172.21.31.254
    tags  = {
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
