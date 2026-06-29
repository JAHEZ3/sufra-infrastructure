terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Bootstrap uses LOCAL state on purpose: it creates the remote backend that
  # every other configuration depends on, so it cannot store state there itself.
  # Commit the resulting terraform.tfstate, or migrate it into the bucket later.
}
