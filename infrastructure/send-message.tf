locals {
  name = "${local.project}-send-message-lambda"
}

module "send_message_lambda" {
  source = "./modules/lambda"

  name          = local.name
  source_bucket = aws_s3_bucket.lambda_source.id
}

module "send_message_codepipeline" {
  source = "./modules/codepipeline-lambda"

  name                     = local.name
  codestar_connection_arn  = aws_codestarconnections_connection._.arn
  repository_id            = "tomwatsonqa/whatsapp-ai-chatbot"
  branch_name              = "main"
  buildspec_path           = "./app/send_message/buildspec.yml"
  codepipeline_bucket_name = aws_s3_bucket.codepipeline.id
  lambda_bucket_name       = aws_s3_bucket.lambda_source.id
  file_paths               = ["/app/send_message/index.py"]

  depends_on = [
    module.send_message_lambda
  ]
}

module "send_message_route" {
  source = "./modules/api-route"

  api_id               = aws_apigatewayv2_api.root.id
  api_execution_arn    = aws_apigatewayv2_api.root.execution_arn
  api_route_key        = "POST /message"
  lambda_function_name = module.send_message_lambda.function_name
  lambda_alias         = module.send_message_lambda.alias_name
}

