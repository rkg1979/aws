# Fetch the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Create your first EC2 instance
resource "aws_instance" "nginx_instance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  tags = {
    Name = "Terraform-First-Instance-nginx"
  }
}

# Output the Public IP of the instance
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.nginx_instance.public_ip
}