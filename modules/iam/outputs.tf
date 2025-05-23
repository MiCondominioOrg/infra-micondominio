output "role_name" {
  value = aws_iam_role.glue_role.name
}

output "policy_arn" {
  value = aws_iam_policy.glue_policy.arn
}
