variable "role_name" {
  type = string
}

variable "policy_statements" {
  type = list(any)
}

variable "tags" {
  type    = map(string)
  default = {}
}