# Remote state for the staging environment.

terraform {
  backend "s3" {
    bucket       = "sufra-terraform-state-220719767281"
    key          = "env/staging/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
