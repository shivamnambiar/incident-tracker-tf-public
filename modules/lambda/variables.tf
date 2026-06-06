# modules/lambda/variables.tf

variable "function_name" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "source_dir" {
  type = string
}

variable "timeout" {
  type    = number
  default = 10
}

variable "environment" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "reserved_concurrent_executions" {
  type    = number
  default = -1
}