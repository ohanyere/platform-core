variable "cluster_oidc_provider_arn" {
  description = "ARN of the EKS cluster IAM OIDC provider."
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "Issuer URL for the EKS cluster OIDC provider, with or without https://."
  type        = string
}

variable "role_name" {
  description = "IAM role name assumed by Crossplane AWS provider pods through IRSA."
  type        = string
  default     = "platform-crossplane-aws-provider"
}

variable "namespace" {
  description = "Namespace where Crossplane provider pods run."
  type        = string
  default     = "crossplane-system"
}

variable "service_account_name_patterns" {
  description = "Service account name patterns allowed to assume the provider role."
  type        = list(string)
  default = [
    "provider-aws-*",
    "provider-family-aws-*",
  ]
}

variable "aws_partition" {
  description = "AWS partition used for IAM resource ARNs."
  type        = string
  default     = "aws"
}

variable "tags" {
  description = "Tags applied to IAM resources."
  type        = map(string)
  default = {
    managed-by = "platform-core"
    component  = "crossplane"
  }
}
