resource "aws_dynamodb_table" "incident_table" {
  name           = "${local.prefix}-incidents"
  billing_mode   = "PROVISIONED"
  hash_key       = "PK"
  range_key      = "SK"
  read_capacity  = 8
  write_capacity = 8

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  attribute {
    name = "createdBy"
    type = "S"
  }

  attribute {
    name = "createdAt"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  global_secondary_index {
    name            = "GSI1-createdBy-index"
    hash_key        = "createdBy"
    range_key       = "createdAt"
    projection_type = "ALL"
    read_capacity   = 8
    write_capacity  = 8
  }

  global_secondary_index {
    name            = "GSI2-status-index"
    hash_key        = "status"
    range_key       = "createdAt"
    projection_type = "ALL"
    read_capacity   = 8
    write_capacity  = 8
  }

  deletion_protection_enabled = false

  tags = local.common_tags
}