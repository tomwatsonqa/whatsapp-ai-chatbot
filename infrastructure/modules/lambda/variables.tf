variable "name" {
  description = "The name of the lambda function and this module instance"
  type        = string
}

variable "timeout" {
  description = "The time the lambda is allowed to run for before timing out"
  type        = number
  default     = 3
}

variable "source_bucket" {
  description = "The S3 bucket the source is stored in"
  type        = string
}

variable "module_name" {
  description = "The name of the python module"
  type        = string
}
