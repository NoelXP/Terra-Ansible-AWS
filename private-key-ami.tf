# Upload a Private Key Pair for SSH instance Authentication
resource "aws_key_pair" "taa-kp-config-user" {
  key_name   = "taa-kp-config-user"
  public_key = file("~/.ssh/taa-kp-user-config.pub")
}

#Find AMI Ubuntu 22.04 ARM64 Server
data "aws_ami" "ubuntu-22-04-arm64-server" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}
#Find AMI Ubuntu 23.04 ARM64 Minimal
data "aws_ami" "ubuntu-23-04-arm64-minimal" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu-minimal/images/hvm-ssd/ubuntu-lunar-23.04-arm64-minimal-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}