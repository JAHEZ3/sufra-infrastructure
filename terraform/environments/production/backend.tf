# Remote state for the production environment.

terraform {
  backend "s3" {
    bucket       = "sufra-terraform-state-220719767281"
    key          = "env/production/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
