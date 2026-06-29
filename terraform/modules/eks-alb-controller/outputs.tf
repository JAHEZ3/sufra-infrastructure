output "role_arn" {
  description = "IAM role ARN to annotate the controller's service account with."
  value       = module.irsa.role_arn
}

output "service_account_name" {
  description = "Service account name the controller should use."
  value       = var.service_account_name
}

output "namespace" {
  description = "Namespace the controller runs in."
  value       = var.namespace
}

output "helm_values_hint" {
  description = "Key Helm values for installing the controller against this role."
  value = {
    "clusterName"                                               = "set to your EKS cluster name"
    "serviceAccount.create"                                     = false
    "serviceAccount.name"                                       = var.service_account_name
    "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.irsa.role_arn
  }
}
