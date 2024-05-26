# Front end server running Ubuntu 23.04 ARM64 Minimal
resource "aws_instance" "taa-ec-front-end-001" {
  ami                    = data.aws_ami.ubuntu-23-04-arm64-minimal.id
  instance_type          = "t4g.micro"
  subnet_id              = aws_subnet.taa-public-sub-00.id
  key_name               = aws_key_pair.taa-kp-config-user.key_name
  vpc_security_group_ids = [aws_security_group.taa-sg-base-ec2.id, aws_security_group.taa-sg-front-end.id]
  tags = {
    Name         = "taa-ec-front-end-001"
    private_name = "taa-ec-front-end-001"
    public_name  = "www"
    app          = "front-end"
    app_ver      = "2.3"
    os           = "ubuntu"
    os_ver       = "23.04"
    os_arch      = "arm64"
    environment  = "production"
    cost_center  = "green-department"
  }
}

# back end server running Ubuntu 22.04 ARM64 Server
resource "aws_instance" "taa-ec-back-end-001" {
  ami                    = data.aws_ami.ubuntu-22-04-arm64-server.id
  instance_type          = "t4g.micro"
  subnet_id              = aws_subnet.taa-public-sub-00.id
  key_name              = aws_key_pair.taa-kp-config-user.key_name
  vpc_security_group_ids = [aws_security_group.taa-sg-base-ec2.id, aws_security_group.taa-sg-back-end.id]
    tags = {
        Name         = "taa-ec-back-end-123"
        private_name = "taa-ec-back-end-123"
        public_name  = "server"
        app          = "back-end"
        app_ver      = "1.2"
        os           = "ubuntu"
        os_ver       = "22.04"
        os_arch      = "arm64"
        environment  = "production"
        cost_center  = "blue-department"
    }   
}
