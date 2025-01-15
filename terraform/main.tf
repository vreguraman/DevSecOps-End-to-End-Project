provider "vault" {
  address = "http://52.90.125.142:8200/"
}

data "vault_generic_secret" "aws_credentials" {
  path = "aws/creds/dev-role"
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}



resource "aws_security_group" "example_sg" {
  name        = "example-sg"
  description = "Allow SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "example-sg"
  }
}

resource "aws_instance" "example_instance" {
  ami           = "ami-05576a079321f21f8" # Amazon Linux 2 AMI (Replace with your region-specific AMI)
  instance_type = "t2.micro"              # Free-tier eligible instance type
  key_name      = "Devsecops"             # Replace with your key pair name

  vpc_security_group_ids = [aws_security_group.example_sg.id] # Attach the security group

  tags = {
    Name = "example-instance"
  }
}
