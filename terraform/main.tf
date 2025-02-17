provider "vault" {
}

data "vault_generic_secret" "aws_credentials" {
  path = "aws/creds/dev-role"
}

provider "aws" {
  region     = "ap-south-1"
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
    cidr_blocks = ["49.204.214.169/32"]  # Restrict SSH access to a specific range
    description = "Allow SSH from private network"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["49.204.214.169/32"]  # Restrict HTTP access to a specific range
    description = "Allow HTTP from private network"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [] # Restrict outbound traffic
    description = "Allow outbound traffic to private network"
  }

  tags = {
    Name = "Sample-Ecommerce-Instance-SG"
  }
  
}

resource "aws_instance" "Sample-Ecommerce-Instance" {
  ami           = "ami-0ddfba243cbee3768" # Replace with your region-specific AMI
  instance_type = "t2.micro"              # Free-tier eligible instance type
  key_name   = "Devsecops"           # SSH key pair name



  root_block_device {
    encrypted = true # Encrypt the root block device
  }

  metadata_options {
    http_tokens = "required" # Require metadata HTTP tokens
  }

  tags = {
  
    Name = "Sample-Ecommerce-Instance"
  }
}
