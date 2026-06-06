# SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "${local.prefix}-alerts"

  tags = local.common_tags

}

# Email subscription
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

locals {
  lambda_functions = {
    createIncident     = module.create_incident.function_name
    getUserIncidents   = module.get_user_incidents.function_name
    getOpenIncidents   = module.get_open_incidents.function_name
    deleteIncident     = module.delete_incident.function_name
    updateIncident     = module.update_incident.function_name
    markStaleIncidents = module.mark_stale_incidents.function_name
  }
}

# ─── Lambda Log Groups ───────────────────────────────────────────

resource "aws_cloudwatch_log_group" "lambda" {
  for_each          = local.lambda_functions
  name              = "/aws/lambda/${each.value}"
  retention_in_days = 30

  depends_on = [
    module.create_incident,
    module.get_user_incidents,
    module.get_open_incidents,
    module.delete_incident,
    module.update_incident,
    module.mark_stale_incidents
  ]

  tags = local.common_tags

}

# ─── Lambda Alarms ───────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each = local.lambda_functions

  alarm_name        = "lambda-errors-${each.key}"
  alarm_description = "Lambda function ${each.key} is throwing errors"
  namespace         = "AWS/Lambda"
  metric_name       = "Errors"
  dimensions = {
    FunctionName = each.value
  }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = local.common_tags

}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  for_each = local.lambda_functions

  alarm_name        = "lambda-duration-${each.key}"
  alarm_description = "Lambda function ${each.key} is running too long"
  namespace         = "AWS/Lambda"
  metric_name       = "Duration"
  dimensions = {
    FunctionName = each.value
  }
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 2400
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = local.common_tags

}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  for_each = local.lambda_functions

  alarm_name        = "lambda-throttles-${each.key}"
  alarm_description = "Lambda function ${each.key} is being throttled"
  namespace         = "AWS/Lambda"
  metric_name       = "Throttles"
  dimensions = {
    FunctionName = each.value
  }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = local.common_tags

}

# ─── API Gateway Alarms ──────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "api_5xx" {
  alarm_name        = "api-gateway-5xx-errors"
  alarm_description = "API Gateway is returning 5xx server errors"
  namespace         = "AWS/ApiGateway"
  metric_name       = "5XXError"
  dimensions = {
    ApiId = aws_apigatewayv2_api.incident_tracker.id
  }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = local.common_tags

}

resource "aws_cloudwatch_metric_alarm" "api_4xx" {
  alarm_name        = "api-gateway-4xx-errors"
  alarm_description = "API Gateway is returning high 4xx client errors"
  namespace         = "AWS/ApiGateway"
  metric_name       = "4XXError"
  dimensions = {
    ApiId = aws_apigatewayv2_api.incident_tracker.id
  }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 10
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = local.common_tags

}

resource "aws_cloudwatch_metric_alarm" "api_latency" {
  alarm_name        = "api-gateway-high-latency"
  alarm_description = "API Gateway latency is too high"
  namespace         = "AWS/ApiGateway"
  metric_name       = "Latency"
  dimensions = {
    ApiId = aws_apigatewayv2_api.incident_tracker.id
  }
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 3000
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = local.common_tags

}

# ─── DynamoDB Alarms ────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "dynamodb_read_throttles" {
  alarm_name        = "dynamodb-read-throttles"
  alarm_description = "DynamoDB is throttling read requests"
  namespace         = "AWS/DynamoDB"
  metric_name       = "ReadThrottleEvents"
  dimensions = {
    TableName = aws_dynamodb_table.incident_table.name
  }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = local.common_tags

}

resource "aws_cloudwatch_metric_alarm" "dynamodb_write_throttles" {
  alarm_name        = "dynamodb-write-throttles"
  alarm_description = "DynamoDB is throttling write requests"
  namespace         = "AWS/DynamoDB"
  metric_name       = "WriteThrottleEvents"
  dimensions = {
    TableName = aws_dynamodb_table.incident_table.name
  }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = local.common_tags

}

# ─── API Gateway Log Group ───────────────────────────────────────

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/apigateway/${local.prefix}"
  retention_in_days = 30
}