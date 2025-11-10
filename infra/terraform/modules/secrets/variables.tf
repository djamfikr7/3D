variable "name" { type = string }
variable "secret_string" { type = string sensitive = true }
variable "kms_key_id" { type = string default = null }
