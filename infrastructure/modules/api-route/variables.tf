variable "api_id" {
  description = "The ID of the api"
  type        = string
}

variable "api_route_key" {
  description = "The key of the api route. Either $default, or a combination of an HTTP method and resource path (e.g. GET /pets)"
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the lambda function"
  type        = string
}

variable "lambda_alias" {
  description = "The name of the lambda alias"
  type        = string
}

variable "api_execution_arn" {
  description = "The api execution ARN"
  type        = string
}
