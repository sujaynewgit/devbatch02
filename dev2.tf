provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}

# Generate an SSH Key Pair (if you already have a key, replace this section)
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "generated_key" {
  key_name   = "dev_2"
  public_key = tls_private_key.my_key.public_key_openssh
}

# Save private key locally
resource "local_file" "private_key" {
  filename = "dev_2.pem"
  content  = tls_private_key.my_key.private_key_pem
}

# Create a Security Group for SSH Access
resource "aws_security_group" "ssh_sg" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all (Change to your IP for security)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 Instance
resource "aws_instance" "web" {
  ami           = "ami-05b10e08d247fb927"  # Replace with a valid AMI ID
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name  # Attach the generated key
  security_groups = [aws_security_group.ssh_sg.name]  # Attach security group

  tags = {
    Name = "dev_batch_2"
  }
}
