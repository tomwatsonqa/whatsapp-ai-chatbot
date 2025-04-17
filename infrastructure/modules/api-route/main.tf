resource "aws_apigatewayv2_route" "_" {
  api_id    = var.api_id
  route_key = var.api_route_key
}

resource "aws_lambda_permission" "_" {
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.api_execution_arn}/*/*"
  qualifier  = var.lambda_alias
}