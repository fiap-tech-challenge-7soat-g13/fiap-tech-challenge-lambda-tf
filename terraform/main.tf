locals {
  runtime = "python3.12"
}

resource "null_resource" "always_run" {
  triggers = {
    timestamp = timestamp()
  }
}

resource "aws_cognito_user_pool" "user_pool" {
  name = "self-order-management"
  username_attributes = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = false
  }
  
  schema {
    attribute_data_type = "String"
    name                = "pasword"
    required            = false
  }

  tags = var.tags

  lifecycle {
    replace_triggered_by = [
      null_resource.always_run
    ]
  }
}

resource "aws_cognito_user_group" "admin" {
  name         = "admin"
  user_pool_id = aws_cognito_user_pool.user_pool.id

  depends_on = [
    aws_cognito_user_pool.user_pool
  ]
}

resource "aws_cognito_user_group" "customer" {
  name                = "customer"
  user_pool_id        = aws_cognito_user_pool.user_pool.id

  depends_on = [
    aws_cognito_user_pool.user_pool
  ]
}

resource "aws_cognito_user_pool_client" "client" {
  name                = "client"

  user_pool_id        = aws_cognito_user_pool.user_pool.id
  explicit_auth_flows = ["ALLOW_ADMIN_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_CUSTOM_AUTH"]
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "auth_sign_up" {
  name   = "auth_sign_up"
  vpc_id = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "lambda_auth_sign_up" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.2.2"

  function_name = "auth-sign-up"
  handler       = "lambda_function.lambda_handler"
  runtime       = local.runtime

  source_path = {
    path             = "../src/sign-up"
    pip_requirements = true
  }

  environment_variables = {
    USER_POOL_ID      = aws_cognito_user_pool.user_pool.id
    TARGET_PORT       = var.target_group_port
  }

  attach_policy_statements = true
  policy_statements = {
    cognito = {
      effect = "Allow"
      actions = [
        "cognito-idp:AdminCreateUser",
        "cognito-idp:AdminGetUser",
        "cognito-idp:AdminAddUserToGroup"
      ]
      resources = [
        aws_cognito_user_pool.user_pool.arn
      ]
    }
  }

  vpc_security_group_ids = [aws_security_group.auth_sign_up.id]
  attach_network_policy  = true
}

module "lambda_auth_sign_in" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.2.2"

  function_name = "auth-sign-in"
  handler       = "lambda_function.lambda_handler"
  runtime       = local.runtime

  source_path = "../src/sign-in"

  environment_variables = {
    USER_POOL_ID = aws_cognito_user_pool.user_pool.id
    CLIENT_ID    = aws_cognito_user_pool_client.client.id
  }

  attach_policy_statements = true
  policy_statements = {
    cognito = {
      effect = "Allow"
      actions = [
        "cognito-idp:AdminInitiateAuth",
        "cognito-idp:AdminGetUser",
      ]
      resources = [
        aws_cognito_user_pool.user_pool.arn
      ]
    }
  }

  tags = var.tags

  depends_on = [
    aws_cognito_user_pool.user_pool
  ]
}

data "aws_lb" "load_balancer" {
  name = "orders-load-balancer"
}

resource "aws_api_gateway_vpc_link" "vpc_link" {
  name        = "self-order-management-api"
  target_arns = [data.aws_lb.load_balancer.arn]
}

resource "aws_api_gateway_rest_api" "api_gateway" {
  name = "Self-Order Management API"

  body = templatefile(
    "${path.module}/../src/api/.generated/api.json",
    {
      target_group_port          = var.target_group_port
      dns_name                   = data.aws_lb.load_balancer.dns_name
      vpc_link_id                = aws_api_gateway_vpc_link.vpc_link.id
      api_gateway_role           = aws_iam_role.api_gateway_lambda.arn
      lambda_auth_sign_up_arn    = data.aws_lambda_function.auth_sign_up.invoke_arn
      lambda_auth_sign_in_arn    = data.aws_lambda_function.auth_sign_in.invoke_arn
      lambda_auth_authorizer_arn = data.aws_lambda_function.auth_authorizer.invoke_arn
    }
  )

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

data "aws_iam_policy_document" "api_gateway" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*/*"]
  }
}

resource "aws_api_gateway_rest_api_policy" "api_gateway" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  policy      = data.aws_iam_policy_document.api_gateway.json
}

resource "aws_api_gateway_deployment" "api_gateway" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api_gateway.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_gateway" {
  stage_name    = "live"
  deployment_id = aws_api_gateway_deployment.api_gateway.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
}