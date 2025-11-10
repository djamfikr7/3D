variable "name" { type = string }
variable "visibility_timeout_seconds" { type = number default = 600 }
variable "create_dlq" { type = bool default = false }
