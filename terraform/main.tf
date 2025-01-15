provider "vault" {
  
}

data "vault_generic_secret" "aws_credentials" {
  path = "aws/creds/dev-role"
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_credentials.data["access_key"]
  secret_key = data.vault_generic_secret.aws_credentials.data["secret_key"]
  region     = "us-east-1"
}
