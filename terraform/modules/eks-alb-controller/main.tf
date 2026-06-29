# AWS Load Balancer Controller IRSA: creates the IAM role + policy the
# controller's service account assumes to manage ALBs/NLBs, target groups,
# listeners, and WAF associations on the cluster's behalf.
#
# This module only provisions the AWS-side IAM. Installing the controller
# itself (Helm) and annotating the service account with role_arn is a
# Kubernetes-layer step done outside Terraform (or via a helm provider).

module "irsa" {
  source = "../irsa"

  project              = var.project
  environment          = var.environment
  name                 = "alb-controller"
  oidc_provider_arn    = var.oidc_provider_arn
  oidc_provider_url    = var.oidc_provider_url
  namespace            = var.namespace
  service_account_name = var.service_account_name

  # Official AWS Load Balancer Controller IAM policy, bundled with this module.
  inline_policy_json = file("${path.module}/iam_policy.json")

  tags = var.tags
}
