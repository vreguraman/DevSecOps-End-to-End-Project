variable "vault_address" {
  description = "Vault server address"
}

variable "vault_token" {
  description = "Vault token for authentication"
  sensitive   = true
}
