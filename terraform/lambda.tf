provider "aws" {
  region = "us-east-1"
}

resource "aws_lambda_function" "this" {
  function_name = "get_cert_expiration"

  s3_bucket = aws_s3_bucket.this
  s3_key    = "v1.0.0/function.zip"

  handler = "main"
  runtime = "go1.x"

  role = "${aws_iam_role.lambda_exec.arn}"
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "this" {
  name = "lambda_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
