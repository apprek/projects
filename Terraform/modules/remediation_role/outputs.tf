output "remediation_role_arn" {
  description = "ARN of the remediation role"
  value       = aws_iam_role.remediation.arn
}

output "can_terminate_resources" {
  description = "Does this role have permission to terminate noncompliant resources?"
  value       = var.allow_terminations
}
