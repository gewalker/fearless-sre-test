// terraform variable definitions  
// Required Inputs:
// s3_bucket_name
// lambda_name

variable "s3_bucket_name" {
  type        = string
  default     = "lambdas.gewalker.net"
  description = "S3 bucket in which the code package for this lambda function is stored."
}

variable "s3_key" {
  type        = string
  default     = "tls_validator/function.zip"
  description = "The AWS S3 key/path to the function code package."
}

variable "lambda_name" {
  type        = string
  default     = "tls_validator"
  description = "The name for the lambda function ()"
}