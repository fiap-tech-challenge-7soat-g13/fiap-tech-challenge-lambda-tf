resource "aws_api_gateway_rest_api" "default" {
  name = "default"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
resource "aws_api_gateway_resource" "login" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  parent_id   = aws_api_gateway_rest_api.default.root_resource_id
  path_part   = "login"
}
resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.default.id
  resource_id   = aws_api_gateway_resource.login.id
  http_method   = "POST"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.default.id
  resource_id             = aws_api_gateway_method.method.resource_id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = module.lambda_auth_sign_in.lambda_function_invoke_arn
}
resource "aws_api_gateway_method_response" "default" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  resource_id = aws_api_gateway_resource.login.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  depends_on = [aws_api_gateway_integration.lambda]
}
resource "aws_api_gateway_integration_response" "default" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  resource_id = aws_api_gateway_resource.login.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = aws_api_gateway_method_response.default.status_code
  response_templates = {
    "application/json" = ""
  }
  depends_on = [aws_api_gateway_integration.lambda]
}
resource "aws_lambda_permission" "default" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_auth_sign_in.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.default.execution_arn}/*/*"
}
resource "aws_api_gateway_deployment" "default" {
  stage_name  = "production"
  rest_api_id = aws_api_gateway_rest_api.default.id
  depends_on = [
    aws_api_gateway_integration.lambda
  ]
}