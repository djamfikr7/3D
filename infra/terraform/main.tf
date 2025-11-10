terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  # TODO: configure remote backend (S3 + DynamoDB)
}

provider "aws" {
  region = var.region
}

variable "region" { default = "us-east-1" }

module "network" {
  source   = "./modules/network"
  cidr     = "10.0.0.0/16"
  az_count = 2
}

module "storage" {
  source       = "./modules/storage"
  bucket_name  = "capture3d-dev-${var.region}"
  force_destroy = true
}

module "queue" {
  source = "./modules/queue"
  name   = "capture3d-jobs"
}

module "database" {
  source                  = "./modules/database"
  db_name                 = "capture3d"
  username                = "appuser"
  password                = "changeme123!"
  instance_class          = "db.t3.micro"
  subnet_ids              = module.network.private_subnet_ids
  vpc_id                  = module.network.vpc_id
}

module "ssm" {
  source    = "./modules/ssm"
  namespace = "capture3d/dev"
  parameters = {
    JWT_SECRET = "change-me-dev"
    S3_BUCKET  = module.storage.bucket_name
  }
}

# Example Secrets Manager (optional)
# module "secrets" {
#   source        = "./modules/secrets"
#   name          = "capture3d/dev/app"
#   secret_string = jsonencode({ db_password = "changeme123!" })
# }
