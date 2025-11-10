variable "db_name" { type = string }
variable "username" { type = string }
variable "password" { type = string }
variable "instance_class" { type = string default = "db.t3.micro" }
variable "subnet_ids" { type = list(string) }
variable "vpc_id" { type = string }
variable "vpc_security_group_ids" { type = list(string) default = [] }
