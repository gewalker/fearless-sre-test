resource "aws_lambda_function" "this" {
  function_name = var.lambda_name

  s3_bucket = var.s3_bucket_name
  s3_key    = var.s3_key
  // not bothering to break these out into variables because this is a POC
  handler = var.lambda_name
  runtime = "go1.x"

  role = aws_iam_role.this.arn
}

// IAM role assumed by lambda function when invoked
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

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = "ANY"
  // Yeah...about this. Not my preference, but this is a POC and I'm not going to stand up authn/authz and tie into it in 48 hrs (at least not
  // in any way I would want anyone to look at later)
  authorization = "NONE"
}

