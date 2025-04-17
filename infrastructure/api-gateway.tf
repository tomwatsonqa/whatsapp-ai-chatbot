resource "aws_apigatewayv2_api" "root" {
  name          = local.project
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "root" {
  api_id = aws_apigatewayv2_api.root.id
  name   = "default"
}




