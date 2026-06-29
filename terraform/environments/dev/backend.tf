# Remote state for the dev environment.
# Create the bucket + lock table once (bootstrap) before `terraform init`.

terraform {
  backend "s3" {
    bucket         = "sufra-terraform-state"
    key            = "env/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "sufra-terraform-locks"
    encrypt        = true
  }
}
