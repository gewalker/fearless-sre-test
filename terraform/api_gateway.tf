resource "aws_api_gateway_rest_api" "this" {
    name = "lambda_api_gateway"
    description = "an api_gateway rest api for lambda access and invocation"
}