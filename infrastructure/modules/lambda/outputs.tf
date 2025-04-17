output "execution_role_arn" {
  value = aws_iam_role._.arn
}
output "execution_policy_arn" {
  value = aws_iam_policy._.arn
}

output "function_name" {
  value = aws_lambda_function._.function_name
}

output "function_arn" {
  value = aws_lambda_function._.arn
}

output "loggroup_name" {
  value = "/aws/lambda/${var.name}"
}

output "invoke_arn" {
  value = aws_lambda_alias._.invoke_arn
}

output "alias_name" {
  value = aws_lambda_alias._.name
}
