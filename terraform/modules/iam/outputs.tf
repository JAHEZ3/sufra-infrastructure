output "eks_cluster_role_arn" {
  description = "ARN of the EKS control plane role."
  value       = try(aws_iam_role.eks_cluster[0].arn, null)
}

output "eks_cluster_role_name" {
  description = "Name of the EKS control plane role."
  value       = try(aws_iam_role.eks_cluster[0].name, null)
}

output "eks_node_role_arn" {
  description = "ARN of the EKS worker node role."
  value       = try(aws_iam_role.eks_node[0].arn, null)
}

output "eks_node_role_name" {
  description = "Name of the EKS worker node role."
  value       = try(aws_iam_role.eks_node[0].name, null)
}
