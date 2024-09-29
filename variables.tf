variable "cognito_database_name" {
  type        = string
  description = "The name of the Cognito database."
}

variable "cognito_database_password_policy_minimum_length" {
  type        = number
  description = "The minimum length for passwords in the Cognito database."
}

variable "cognito_database_password_policy_require_uppercase" {
  type        = bool
  description = "Whether to require uppercase letters in passwords."
}

variable "cognito_database_password_policy_require_lowercase" {
  type        = bool
  description = "Whether to require lowercase letters in passwords."
}

variable "cognito_database_password_policy_require_numbers" {
  type        = bool
  description = "Whether to require numbers in passwords."
}

variable "cognito_database_password_policy_require_symbols" {
  type        = bool
  description = "Whether to require symbols in passwords."
}

variable "cognito_database_password_policy_temporary_password_validity_days" {
  type        = number
  description = "The number of days temporary passwords are valid."
}

variable "cognito_database_auto_verified_attributes" {
  type        = list(string)
  description = "The attributes that Cognito automatically verifies."
}

variable "cognito_database_account_recovery_setting_recovery_mechanism_name" {
  type        = string
  description = "The recovery mechanism name for account recovery."
}

variable "cognito_database_account_recovery_setting_recovery_mechanism_priority" {
  type        = number
  description = "The priority of the account recovery mechanism."
}

variable "cognito_database_admin_create_user_config_allow_admin_create_user_only" {
  type        = bool
  description = "Whether to allow only administrators to create users."
}

variable "cognito_database_email_configuration_email_sending_account" {
  type        = string
  description = "The email sending account configuration."
}

variable "cognito_database_user_pool_name" {
  type        = string
  description = "The name of the Cognito user pool."
}

variable "cognito_database_user_pool_generate_secret" {
  type        = bool
  description = "Whether to generate a client secret for the user pool."
}

variable "cognito_database_user_pool_explicit_auth_flows" {
  type        = list(string)
  description = "The explicit authentication flows allowed for the user pool."
}

variable "cognito_database_user_pool_refresh_token_validity" {
  type        = number
  description = "The number of days the refresh token is valid."
}