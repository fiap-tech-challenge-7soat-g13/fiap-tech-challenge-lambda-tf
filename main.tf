terraform {
  backend "s3" {
    bucket = "terraform-state-829dbe75"
    key    = "taste-food-lambda"
    region = "us-east-1"
  }
}
provider "aws" {
  region = var.region
}
data "aws_vpc" "default" {
  default = true
}

resource "aws_cognito_user_pool" "cognito_user_pool_taste_food" {
  name = var.cognito_database_name

  password_policy {
    minimum_length                   = var.cognito_database_password_policy_minimum_length
    require_uppercase                = var.cognito_database_password_policy_require_uppercase
    require_lowercase                = var.cognito_database_password_policy_require_lowercase
    require_numbers                  = var.cognito_database_password_policy_require_numbers
    require_symbols                  = var.cognito_database_password_policy_require_symbols
    temporary_password_validity_days = var.cognito_database_password_policy_temporary_password_validity_days
  }

  auto_verified_attributes = var.cognito_database_auto_verified_attributes

  account_recovery_setting {
    recovery_mechanism {
      name     = var.cognito_database_account_recovery_setting_recovery_mechanism_name
      priority = var.cognito_database_account_recovery_setting_recovery_mechanism_priority
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = var.cognito_database_admin_create_user_config_allow_admin_create_user_only
  }

  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
    mutable             = false
  }

  schema {
    attribute_data_type = "String"
    name                = "name"
    required            = true
    mutable             = true
  }

  email_configuration {
    email_sending_account = var.cognito_database_email_configuration_email_sending_account
  }
}

resource "aws_cognito_user_pool_client" "cognito_user_pool_client_taste_food" {
  name                   = var.cognito_database_user_pool_name
  user_pool_id           = aws_cognito_user_pool.cognito_user_pool_taste_food.id
  generate_secret        = var.cognito_database_user_pool_generate_secret
  explicit_auth_flows    = var.cognito_database_user_pool_explicit_auth_flows
  refresh_token_validity = var.cognito_database_user_pool_refresh_token_validity
}