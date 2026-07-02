output "role_arn" {
  description = "Annotate the Crossplane AWS provider service account with this ARN."
  value       = aws_iam_role.crossplane_provider.arn
}

output "service_account_annotation" {
  description = "Annotation value required by crossplane/providers/aws-irsa-runtime-config.yaml."
  value       = "eks.amazonaws.com/role-arn: ${aws_iam_role.crossplane_provider.arn}"
}
