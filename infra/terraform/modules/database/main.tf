# Minimal RDS Postgres for dev
resource "aws_db_subnet_group" "this" {
  name       = "capture3d-db-subnet"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "db" {
  name        = "capture3d-db-sg"
  description = "DB access"
  vpc_id      = var.vpc_id
}

resource "aws_db_instance" "this" {
  identifier              = "capture3d-postgres"
  engine                  = "postgres"
  engine_version          = "15"
  instance_class          = var.instance_class
  username                = var.username
  password                = var.password
  db_name                 = var.db_name
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  allocated_storage       = 20
  skip_final_snapshot     = true
  publicly_accessible     = false
  deletion_protection     = false
}
