module "create_incident" {
  source        = "./modules/lambda"
  function_name = "${local.prefix}-create-incident"
  role_arn      = module.create_incident_role.arn
  source_dir    = "./lambda/createIncident"
  environment   = { TABLE_NAME = aws_dynamodb_table.incident_table.name }
  tags          = local.common_tags
}

module "get_user_incidents" {
  source        = "./modules/lambda"
  function_name = "${local.prefix}-get-user-incidents"
  role_arn      = module.get_user_incidents_role.arn
  source_dir    = "./lambda/getUserIncidents"
  environment   = { TABLE_NAME = aws_dynamodb_table.incident_table.name }
  tags          = local.common_tags
}

module "get_open_incidents" {
  source        = "./modules/lambda"
  function_name = "${local.prefix}-get-open-incidents"
  role_arn      = module.get_open_incidents_role.arn
  source_dir    = "./lambda/getOpenIncidents"
  environment   = { TABLE_NAME = aws_dynamodb_table.incident_table.name }
  tags          = local.common_tags
}

module "delete_incident" {
  source        = "./modules/lambda"
  function_name = "${local.prefix}-delete-incident"
  role_arn      = module.delete_incident_role.arn
  source_dir    = "./lambda/deleteIncident"
  environment   = { TABLE_NAME = aws_dynamodb_table.incident_table.name }
  tags          = local.common_tags
}

module "update_incident" {
  source        = "./modules/lambda"
  function_name = "${local.prefix}-update-incident"
  role_arn      = module.update_incident_role.arn
  source_dir    = "./lambda/updateIncident"
  environment   = { TABLE_NAME = aws_dynamodb_table.incident_table.name }
  tags          = local.common_tags
}

module "mark_stale_incidents" {
  source        = "./modules/lambda"
  function_name = "${local.prefix}-mark-stale-incidents"
  role_arn      = module.mark_stale_incidents_role.arn
  source_dir    = "./lambda/markStaleIncidents"
  timeout       = 30
  environment   = { TABLE_NAME = aws_dynamodb_table.incident_table.name }
  tags          = local.common_tags
}