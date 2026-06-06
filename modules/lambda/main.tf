# modules/lambda/main.tf

data "archive_file" "this" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${var.source_dir}.zip"
}

resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  role             = var.role_arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.13"
  architectures    = ["arm64"]
  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256
  reserved_concurrent_executions = var.reserved_concurrent_executions
  timeout          = var.timeout
  kms_key_arn      = null

  environment {
    variables = var.environment
  }

  tags = var.tags
}