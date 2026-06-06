resource "aws_cognito_user_pool" "incident_tracker" {
  name = "${local.prefix}-user-pool"

  # Sign in with email or phone
  username_attributes = ["email"]

  # Self registration disabled
  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  # Password policy (Cognito defaults)
  password_policy {
    minimum_length                   = 8
    require_uppercase                = true
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  # MFA - off
  mfa_configuration = "OFF"

  tags = local.common_tags
}

# Hosted UI domain
resource "aws_cognito_user_pool_domain" "incident_tracker" {
  domain       = "${local.prefix}-auth-${random_id.suffix_cognito.hex}"
  user_pool_id = aws_cognito_user_pool.incident_tracker.id
}

# Random suffix to make domain unique
resource "random_id" "suffix_cognito" {
  byte_length = 4
}

# App client
resource "aws_cognito_user_pool_client" "incident_tracker_app" {
  name         = "${local.prefix}-app-client"
  user_pool_id = aws_cognito_user_pool.incident_tracker.id

  # SPA - no client secret
  generate_secret = false

  # Callback and redirect URLs
  callback_urls = ["https://${aws_cloudfront_distribution.frontend.domain_name}"
  ]
  default_redirect_uri = "https://${aws_cloudfront_distribution.frontend.domain_name}"
  logout_urls          = ["https://${aws_cloudfront_distribution.frontend.domain_name}"]

  # Authorization Code + PKCE
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["email", "openid"]

  # Identity providers
  supported_identity_providers = ["COGNITO"]

  # general security settings for auth code
  enable_token_revocation       = true
  prevent_user_existence_errors = "ENABLED"

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  # Token validity
  access_token_validity  = 1
  id_token_validity      = 1
  refresh_token_validity = 30

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
}