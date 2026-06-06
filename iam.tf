module "get_user_incidents_role" {
  source    = "./modules/lambda_role"
  role_name = "${local.prefix}-get-user-incidents-role"
  tags      = local.common_tags

  policy_statements = [{
    Effect = "Allow"
    Action = ["dynamodb:Query"]
    Resource = [
      "${aws_dynamodb_table.incident_table.arn}/index/GSI1-createdBy-index"
    ]
  }]
}

module "get_open_incidents_role" {
  source    = "./modules/lambda_role"
  role_name = "${local.prefix}-get-open-incidents-role"
  tags      = local.common_tags

  policy_statements = [{
    Effect = "Allow"
    Action = ["dynamodb:Query"]
    Resource = [
      "${aws_dynamodb_table.incident_table.arn}/index/GSI2-status-index"
    ]
  }]
}

module "create_incident_role" {
  source    = "./modules/lambda_role"
  role_name = "${local.prefix}-create-incident-role"
  tags      = local.common_tags

  policy_statements = [{
    Effect   = "Allow"
    Action   = ["dynamodb:PutItem"]
    Resource = [aws_dynamodb_table.incident_table.arn]
  }]
}

module "update_incident_role" {
  source    = "./modules/lambda_role"
  role_name = "${local.prefix}-update-incident-role"
  tags      = local.common_tags

  policy_statements = [{
    Effect   = "Allow"
    Action   = ["dynamodb:GetItem", "dynamodb:UpdateItem"]
    Resource = [aws_dynamodb_table.incident_table.arn]
  }]
}

module "delete_incident_role" {
  source    = "./modules/lambda_role"
  role_name = "${local.prefix}-delete-incident-role"
  tags      = local.common_tags

  policy_statements = [{
    Effect   = "Allow"
    Action   = ["dynamodb:GetItem", "dynamodb:DeleteItem"]
    Resource = [aws_dynamodb_table.incident_table.arn]
  }]
}

module "mark_stale_incidents_role" {
  source    = "./modules/lambda_role"
  role_name = "${local.prefix}-mark-stale-incidents-role"
  tags      = local.common_tags

  policy_statements = [{
    Effect = "Allow"
    Action = ["dynamodb:Query", "dynamodb:UpdateItem"]
    Resource = [
      aws_dynamodb_table.incident_table.arn,
      "${aws_dynamodb_table.incident_table.arn}/index/GSI2-status-index"
    ]
  }]
}
