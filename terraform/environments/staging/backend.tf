# Remote state for the staging environment.

terraform {
  backend "s3" {
    bucket         = "sufra-terraform-state"
    key            = "env/staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "sufra-terraform-locks"
    encrypt        = true
  }
}
