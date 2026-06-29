# ECR module: one repository per entry in var.repositories, with optional
# image scanning, encryption, and a lifecycle policy that prunes old images.

locals {
  name = "${var.project}-${var.environment}"

  # Map of "<project>-<env>-<repo>" => repo, used as for_each keys.
  repositories = {
    for repo in var.repositories :
    repo => "${local.name}-${repo}"
  }
}

resource "aws_ecr_repository" "this" {
  for_each = local.repositories

  name                 = each.value
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.encryption_type == "KMS" ? var.kms_key_arn : null
  }

  tags = merge(var.tags, {
    Name = each.value
  })
}

# Retain only the most recent N images per repository.
resource "aws_ecr_lifecycle_policy" "this" {
  for_each = var.max_image_count > 0 ? aws_ecr_repository.this : {}

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${var.max_image_count} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.max_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
