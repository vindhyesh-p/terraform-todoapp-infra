variable "secret_name" {
  type = string
}

variable "secret_value" {
  type      = string
  sensitive = true
}

variable "key_vault_id" {
  type = string
}