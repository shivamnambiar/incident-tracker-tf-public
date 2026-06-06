# The HTTP API
resource "aws_apigatewayv2_api" "incident_tracker" {
  name          = "${local.prefix}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["https://${aws_cloudfront_distribution.frontend.domain_name}"]
    allow_methods = ["GET", "POST", "PATCH", "DELETE", "OPTIONS"]
    allow_headers = ["Authorization", "Content-Type"]
    max_age       = 300
  }
}

# Default stage with auto-deploy and throttling
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.incident_tracker.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 20
    throttling_rate_limit  = 10
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn
    format = jsonencode({
      requestId         = "$context.requestId"
      ip                = "$context.identity.sourceIp"
      requestTime       = "$context.requestTime"
      requestTimeEpoch  = "$context.requestTimeEpoch"
      httpMethod        = "$context.httpMethod"
      routeKey          = "$context.routeKey"
      status            = "$context.status"
      responseLength    = "$context.responseLength"
      latency           = "$context.integrationLatency"
      integrationStatus = "$context.integrationStatus"
      userAgent         = "$context.identity.userAgent"
    })
  }
}

# Cognito JWT Authorizer
resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.incident_tracker.id
  authorizer_type  = "JWT"
  name             = "CognitoAuthorizer"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    issuer   = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.incident_tracker.id}"
    audience = [aws_cognito_user_pool_client.incident_tracker_app.id]
  }
}

# Lambda integrations
resource "aws_apigatewayv2_integration" "create_incident" {
  api_id                 = aws_apigatewayv2_api.incident_tracker.id
  integration_type       = "AWS_PROXY"
  integration_uri        = module.create_incident.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "get_user_incidents" {
  api_id                 = aws_apigatewayv2_api.incident_tracker.id
  integration_type       = "AWS_PROXY"
  integration_uri        = module.get_user_incidents.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "get_open_incidents" {
  api_id                 = aws_apigatewayv2_api.incident_tracker.id
  integration_type       = "AWS_PROXY"
  integration_uri        = module.get_open_incidents.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "delete_incident" {
  api_id                 = aws_apigatewayv2_api.incident_tracker.id
  integration_type       = "AWS_PROXY"
  integration_uri        = module.delete_incident.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "update_incident" {
  api_id                 = aws_apigatewayv2_api.incident_tracker.id
  integration_type       = "AWS_PROXY"
  integration_uri        = module.update_incident.invoke_arn
  payload_format_version = "2.0"
}

# Routes
resource "aws_apigatewayv2_route" "post_incidents" {
  api_id             = aws_apigatewayv2_api.incident_tracker.id
  route_key          = "POST /incidents"
  target             = "integrations/${aws_apigatewayv2_integration.create_incident.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_route" "get_incidents" {
  api_id             = aws_apigatewayv2_api.incident_tracker.id
  route_key          = "GET /incidents"
  target             = "integrations/${aws_apigatewayv2_integration.get_user_incidents.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_route" "get_open" {
  api_id             = aws_apigatewayv2_api.incident_tracker.id
  route_key          = "GET /incidents/open"
  target             = "integrations/${aws_apigatewayv2_integration.get_open_incidents.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_route" "patch_incident" {
  api_id             = aws_apigatewayv2_api.incident_tracker.id
  route_key          = "PATCH /incidents/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.update_incident.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_route" "delete_incident" {
  api_id             = aws_apigatewayv2_api.incident_tracker.id
  route_key          = "DELETE /incidents/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.delete_incident.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
  authorization_type = "JWT"
}

# Lambda permissions
resource "aws_lambda_permission" "create_incident" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.create_incident.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.incident_tracker.execution_arn}/*/*"
}

resource "aws_lambda_permission" "get_user_incidents" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.get_user_incidents.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.incident_tracker.execution_arn}/*/*"
}

resource "aws_lambda_permission" "get_open_incidents" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.get_open_incidents.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.incident_tracker.execution_arn}/*/*"
}

resource "aws_lambda_permission" "delete_incident" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.delete_incident.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.incident_tracker.execution_arn}/*/*"
}

resource "aws_lambda_permission" "update_incident" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.update_incident.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.incident_tracker.execution_arn}/*/*"
}
