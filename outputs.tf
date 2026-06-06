output "api_gateway_url" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_stage.default.invoke_url
  sensitive   = true
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.incident_tracker.id
  sensitive   = true
}

output "cognito_client_id" {
  description = "Cognito App Client ID"
  value       = aws_cognito_user_pool_client.incident_tracker_app.id
  sensitive   = true
}

output "cognito_hosted_ui_url" {
  description = "Cognito Hosted UI login URL"
  value       = "https://${aws_cognito_user_pool_domain.incident_tracker.domain}.auth.${var.aws_region}.amazoncognito.com"
  sensitive   = true
}

output "cloudfront_url" {
  description = "CloudFront distribution URL"
  value       = "https://${aws_cloudfront_distribution.frontend.domain_name}"
  sensitive   = true
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.frontend.id
  sensitive   = true
}

output "cloudfront_distribution_id" {
  value     = aws_cloudfront_distribution.frontend.id
  sensitive = true
}