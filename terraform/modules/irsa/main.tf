# Generic IRSA (IAM Roles for Service Accounts) module: creates an IAM role
# a specific Kubernetes service account can assume via the cluster's OIDC
# provider, then attaches managed and/or an inline customer-managed policy.

locals {
  name = "${var.project}-${var.environment}-${var.name}"

  # The OIDC subject must match the exact service account:
  #   system:serviceaccount:<namespace>:<service_account_name>
  oidc_subject  = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
  oidc_audience = "sts.amazonaws.com"
}

data "aws_iam_policy_document" "assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = [local.oidc_subject]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:aud"
      values   = [local.oidc_audience]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = merge(var.tags, {
    Name = local.name
  })
}

resource "aws_iam_policy" "this" {
  count = var.inline_policy_json != null ? 1 : 0

  name   = "${local.name}-policy"
  policy = var.inline_policy_json

  tags = merge(var.tags, {
    Name = "${local.name}-policy"
  })
}

resource "aws_iam_role_policy_attachment" "inline" {
  count = var.inline_policy_json != null ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this[0].arn
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}
