resource "aws_cloudwatch_dashboard" "incident_tracker" {
  dashboard_name = local.prefix

  dashboard_body = jsonencode({
    widgets = [

      # ─── Lambda Errors ───────────────────────────────────────────
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Lambda Errors"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Sum"
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", module.create_incident.function_name],
            ["AWS/Lambda", "Errors", "FunctionName", module.get_user_incidents.function_name],
            ["AWS/Lambda", "Errors", "FunctionName", module.get_open_incidents.function_name],
            ["AWS/Lambda", "Errors", "FunctionName", module.delete_incident.function_name],
            ["AWS/Lambda", "Errors", "FunctionName", module.update_incident.function_name],
            ["AWS/Lambda", "Errors", "FunctionName", module.mark_stale_incidents.function_name],
          ]
        }
      },

      # ─── Lambda Duration ─────────────────────────────────────────
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Lambda Duration (ms)"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Average"
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", module.create_incident.function_name],
            ["AWS/Lambda", "Duration", "FunctionName", module.get_user_incidents.function_name],
            ["AWS/Lambda", "Duration", "FunctionName", module.get_open_incidents.function_name],
            ["AWS/Lambda", "Duration", "FunctionName", module.delete_incident.function_name],
            ["AWS/Lambda", "Duration", "FunctionName", module.update_incident.function_name],
            ["AWS/Lambda", "Duration", "FunctionName", module.mark_stale_incidents.function_name],
          ]
        }
      },
      # ─── Lambda Invocations ────────────────────────────────────────
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "Lambda Invocations"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Sum"
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", module.create_incident.function_name],
            ["AWS/Lambda", "Invocations", "FunctionName", module.get_user_incidents.function_name],
            ["AWS/Lambda", "Invocations", "FunctionName", module.get_open_incidents.function_name],
            ["AWS/Lambda", "Invocations", "FunctionName", module.delete_incident.function_name],
            ["AWS/Lambda", "Invocations", "FunctionName", module.update_incident.function_name],
            ["AWS/Lambda", "Invocations", "FunctionName", module.mark_stale_incidents.function_name],
          ]
        }
      },
      # ─── Lambda Throttles ────────────────────────────────────────
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "Lambda Throttles"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Sum"
          metrics = [
            ["AWS/Lambda", "Throttles", "FunctionName", module.create_incident.function_name],
            ["AWS/Lambda", "Throttles", "FunctionName", module.get_user_incidents.function_name],
            ["AWS/Lambda", "Throttles", "FunctionName", module.get_open_incidents.function_name],
            ["AWS/Lambda", "Throttles", "FunctionName", module.delete_incident.function_name],
            ["AWS/Lambda", "Throttles", "FunctionName", module.update_incident.function_name],
            ["AWS/Lambda", "Throttles", "FunctionName", module.mark_stale_incidents.function_name],
          ]
        }
      },

      # ─── API Gateway 4xx / 5xx Errors ────────────────────────────
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "API Gateway 4xx / 5xx Errors"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Sum"
          metrics = [
            ["AWS/ApiGateway", "4XXError", "ApiId", aws_apigatewayv2_api.incident_tracker.id],
            ["AWS/ApiGateway", "5XXError", "ApiId", aws_apigatewayv2_api.incident_tracker.id],
          ]
        }
      },

      # ─── API Gateway Latency ─────────────────────────────────────
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "API Gateway Latency (ms)"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Average"
          metrics = [
            ["AWS/ApiGateway", "Latency", "ApiId", aws_apigatewayv2_api.incident_tracker.id],
          ]
        }
      },

      # ─── DynamoDB Throttles ──────────────────────────────────────
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "DynamoDB Throttles"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Sum"
          metrics = [
            ["AWS/DynamoDB", "ReadThrottleEvents", "TableName", aws_dynamodb_table.incident_table.name],
            ["AWS/DynamoDB", "WriteThrottleEvents", "TableName", aws_dynamodb_table.incident_table.name],
          ]
        }
      },

    ]
  })
}