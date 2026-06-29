# Remote state for the dev environment.
# Create the bucket + lock table once (bootstrap) before `terraform init`.

terraform {
  backend "s3" {
    bucket       = "sufra-terraform-state-220719767281"
    key          = "env/dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
