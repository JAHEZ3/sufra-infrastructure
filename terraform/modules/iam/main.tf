# IAM module: service roles for the EKS control plane and worker nodes.

locals {
  name = "${var.project}-${var.environment}"
}

# ---------------------------------------------------------------------------
# EKS cluster (control plane) role
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "eks_cluster_assume" {
  count = var.create_eks_cluster_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  count = var.create_eks_cluster_role ? 1 : 0

  name               = "${local.name}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume[0].json

  tags = merge(var.tags, {
    Name = "${local.name}-eks-cluster-role"
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  count = var.create_eks_cluster_role ? 1 : 0

  role       = aws_iam_role.eks_cluster[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ---------------------------------------------------------------------------
# EKS node group (worker) role
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "eks_node_assume" {
  count = var.create_eks_node_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node" {
  count = var.create_eks_node_role ? 1 : 0

  name               = "${local.name}-eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume[0].json

  tags = merge(var.tags, {
    Name = "${local.name}-eks-node-role"
  })
}

# Managed policies required by EKS managed node groups.
locals {
  node_managed_policies = var.create_eks_node_role ? toset(concat([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ], var.node_additional_policy_arns)) : toset([])
}

resource "aws_iam_role_policy_attachment" "eks_node" {
  for_each = local.node_managed_policies

  role       = aws_iam_role.eks_node[0].name
  policy_arn = each.value
}
