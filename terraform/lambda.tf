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

// API gateway resources associated with the lambda. The API gateway is being used here as a kind of brute force 
// "everything goes to the same place regardless" http router. There are better (but really no quicker or dirtier)
// ways to do this, and frankly this pattern works surprisingly well up to pretty large scales, especially using golang
// in the backend of the function. My biggest gripe is that there are two proxies created simply because the proxy can't
// match both "anthying" and "nothing" without a second match for the root.
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

resource "aws_api_gateway_integration" "this" {
  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.this.invoke_arn}"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  resource_id = "${aws_api_gateway_rest_api.this.root_resource_id}"
  http_method = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.this.invoke_arn}"
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    "aws_api_gateway_integration.this",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  stage_name = "dev"
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.this.function_name}"
  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}