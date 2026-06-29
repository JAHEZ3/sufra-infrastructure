# Bootstrap: creates the remote state backend that every environment uses -
# an encrypted, versioned S3 bucket. State locking uses S3 native lockfiles
# (use_lockfile = true in each backend), so no DynamoDB table is needed.
#
# Run this ONCE, with local state, before `terraform init` in any environment:
#   cd terraform/bootstrap
#   terraform init
#   terraform apply

# ---------------------------------------------------------------------------
# State bucket
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "state" {
  bucket = var.state_bucket_name

  # Guard against accidental `terraform destroy` wiping all state history.
  lifecycle {
    prevent_destroy = true
  }

  tags = merge(var.tags, {
    Name = var.state_bucket_name
  })
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
