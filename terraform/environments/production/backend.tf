# Remote state for the production environment.

terraform {
  backend "s3" {
    bucket         = "sufra-terraform-state"
    key            = "env/production/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "sufra-terraform-locks"
    encrypt        = true
  }
}
