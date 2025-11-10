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

# module "network" { source = "./modules/network" }
# module "database" { source = "./modules/database" }
# module "queue" { source = "./modules/queue" }
# module "storage" { source = "./modules/storage" }
# module "compute_api" { source = "./modules/compute_api" }
# module "compute_gpu" { source = "./modules/compute_gpu" }
# module "cdn" { source = "./modules/cdn" }
