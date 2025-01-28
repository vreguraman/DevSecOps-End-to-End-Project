provider "vault" {
}

data "vault_generic_secret" "aws_credentials" {
  path = "aws/creds/dev-role"
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}



resource "aws_security_group" "Sample-Ecommerce-Instance-SG" {
  name        = "Sample-Ecommerce-Instance-SG"
  description = "Allow restricted SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict SSH access to a specific range
    description = "Allow SSH from private network"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict HTTP access to a specific range
    description = "Allow HTTP from private network"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Restrict outbound traffic
    description = "Allow outbound traffic to private network"
  }

  tags = {
    Name = "Sample-Ecommerce-Instance-SG"
  }
}

resource "aws_instance" "Sample-Ecommerce-Instance" {
  ami           = "ami-05576a079321f21f8" # Replace with your region-specific AMI
  instance_type = "t2.micro"              # Free-tier eligible instance type
  key_name   = "Devsecops"           # SSH key pair name

  vpc_security_group_ids = [aws_security_group.example_sg.id] # Attach the security group

  root_block_device {
    encrypted = true # Encrypt the root block device
  }

  metadata_options {
    http_tokens = "required" # Require metadata HTTP tokens
  }

  tags = {
    environment = "prod"
    Name = "Sample-Ecommerce-Instance"
  }
}
