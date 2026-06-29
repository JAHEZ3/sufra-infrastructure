# GitHub Actions OIDC: lets the CI workflows assume an AWS role without any
# long-lived access keys. Enable by setting create_github_oidc = true and
# supplying github_owner + github_repo, then put the role ARN output into the
# repo secret AWS_ROLE_ARN.

locals {
  github_oidc_enabled = var.create_github_oidc

  # Default: trust any branch/tag/environment of the named repo.
  github_subjects = coalesce(
    var.github_subject_claims,
    ["repo:${var.github_owner}/${var.github_repo}:*"],
  )
}

data "aws_iam_policy_document" "github_assume" {
  count = local.github_oidc_enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github[0].arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.github_subjects
    }
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  count = local.github_oidc_enabled ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # GitHub's OIDC thumbprint; AWS now validates the cert chain so this is a
  # placeholder kept for provider compatibility.
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = merge(var.tags, {
    Name = "${var.project}-github-actions"
  })
}

resource "aws_iam_role" "github_ci" {
  count = local.github_oidc_enabled ? 1 : 0

  name               = "${var.project}-github-ci"
  assume_role_policy = data.aws_iam_policy_document.github_assume[0].json

  tags = merge(var.tags, {
    Name = "${var.project}-github-ci"
  })
}

resource "aws_iam_role_policy_attachment" "github_ci" {
  count = local.github_oidc_enabled ? 1 : 0

  role       = aws_iam_role.github_ci[0].name
  policy_arn = var.ci_role_policy_arn
}
