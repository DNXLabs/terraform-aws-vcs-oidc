output "roles" {
  value = { for role_name, role_values in element(aws_iam_role.default.*, 0) : role_name => role_values.arn }
}

output "identity_provider_arn" {
  value = aws_iam_openid_connect_provider.default.arn
}