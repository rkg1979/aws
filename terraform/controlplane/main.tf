# Fetch the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}
# Create/manage the key pair using Terraform
resource "aws_key_pair" "my_auth" {
  key_name   = "my-ssh-private-key"
  public_key = file("~/.ssh/aws_key.pub") # Path to your local public key
}
resource "aws_security_group" "nginx_sg" {
  name        = "nginx_sg"
  description = "Allow inbound SSH traffic"

  ingress {
    description = "SSH from anywhere (or restrict to your IP)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Best practice: replace with your local IP like "X.X.X.X/32"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx_sg"
  }
}

# 2. Create your EC2 instance attached to the security group
resource "aws_instance" "nginx_instance" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.my_auth.key_name
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]

  tags = {
    Name = "nginx_instance"
  }
}

# Output the Public IP of the instance
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.nginx_instance.public_ip
}
