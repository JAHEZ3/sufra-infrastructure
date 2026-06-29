# EKS module: control plane, managed node groups, and the OIDC provider
# required for IAM Roles for Service Accounts (IRSA).

locals {
  name = "${var.project}-${var.environment}"
}

# ---------------------------------------------------------------------------
# Control plane
# ---------------------------------------------------------------------------
resource "aws_eks_cluster" "this" {
  name     = "${local.name}-eks"
  version  = var.cluster_version
  role_arn = var.cluster_role_arn

  enabled_cluster_log_types = var.enabled_cluster_log_types

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
    public_access_cidrs     = var.public_access_cidrs
  }

  tags = merge(var.tags, {
    Name = "${local.name}-eks"
  })
}

# ---------------------------------------------------------------------------
# OIDC provider for IRSA
# ---------------------------------------------------------------------------
data "tls_certificate" "oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc" {
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]

  tags = merge(var.tags, {
    Name = "${local.name}-eks-oidc"
  })
}

# ---------------------------------------------------------------------------
# Managed node groups
# ---------------------------------------------------------------------------
resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.name}-${each.key}"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type
  disk_size      = each.value.disk_size
  labels         = each.value.labels

  scaling_config {
    desired_size = each.value.desired_size
    min_size     = each.value.min_size
    max_size     = each.value.max_size
  }

  update_config {
    max_unavailable = 1
  }

  tags = merge(var.tags, {
    Name = "${local.name}-${each.key}"
  })

  # desired_size may drift when a cluster autoscaler is in use.
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
