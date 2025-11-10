output "names" { value = [for p in aws_ssm_parameter.this : p.name] }
