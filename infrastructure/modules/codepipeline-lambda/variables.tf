variable "name" {
  description = "The resource name"
  type        = string
}

variable "codepipeline_bucket_name" {
  description = "The name of the codepipeline S3 bucket"
  type        = string
}

variable "lambda_bucket_name" {
  description = "The name of the lambda S3 bucket"
  type        = string
}

variable "codestar_connection_arn" {
  description = "The ARN of the codestar connection"
  type        = string
}

variable "repository_id" {
  description = "The ID of the git repository (e.g. organisation/repo-name)"
  type        = string
}

variable "branch_name" {
  description = "The name of the git branch"
  type        = string
}

variable "module_name" {
  description = "The name of the python module"
  type        = string
}
