# To enable remote state, uncomment and set real values
# terraform {
#   backend "s3" {
#     bucket         = "capture3d-tf-state"
#     key            = "envs/dev/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "capture3d-tf-locks"
#     encrypt        = true
#   }
# }
