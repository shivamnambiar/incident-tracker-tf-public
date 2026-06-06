# IAM role for EventBridge to invoke Lambda
resource "aws_iam_role" "eventbridge_role" {
  name = "${local.prefix}-eventbridge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

# Policy allowing EventBridge to invoke the Lambda
resource "aws_iam_role_policy" "eventbridge_lambda_policy" {
  name = "${local.prefix}-eventbridge-lambda-policy"
  role = aws_iam_role.eventbridge_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = module.mark_stale_incidents.arn
      }
    ]
  })
}

# EventBridge scheduler - runs markStaleIncidents daily at midnight UTC
resource "aws_scheduler_schedule" "mark_stale_incidents" {
  name       = "${local.prefix}-mark-stale-incidents-daily"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(0 0 * * ? *)"

  target {
    arn      = module.mark_stale_incidents.arn
    role_arn = aws_iam_role.eventbridge_role.arn

    input = jsonencode({
      source = "eventbridge-scheduler"
    })

    retry_policy {
      maximum_retry_attempts = 3
    }
  }
}
