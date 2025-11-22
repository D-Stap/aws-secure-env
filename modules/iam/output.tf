output "terraform_execution_role_arn" {
  value = aws_iam_role.terraform_execution.arn
}

output "security_readonly_role_arn" {
  value = aws_iam_role.security_readonly.arn
}
