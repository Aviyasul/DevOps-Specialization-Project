provider "aws" {
  region = "us-east-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical Ubuntu owner ID
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Security Group for EC2
resource "aws_security_group" "builder_sg" {
  name        = "builder-sg-aviya"
  description = "Security Group for builder EC2"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
     cidr_blocks = ["3.146.206.111/32"]  # only your current public IP
}

  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # optional: public access to app
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "builder"
  }
}

# Generate SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/builder_key.pem"
  file_permission = "0600"
}

# Create AWS key pair
resource "aws_key_pair" "builder_key" {
  key_name   = "builder-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# EC2 instance
resource "aws_instance" "builder" {
  ami                       = data.aws_ami.ubuntu.id
  instance_type             = var.instance_type
  subnet_id                 = var.subnet_id
  vpc_security_group_ids    = [aws_security_group.builder_sg.id]
  key_name                  = aws_key_pair.builder_key.key_name
  associate_public_ip_address = true

  tags = {
    Name = "builder"
  }
}