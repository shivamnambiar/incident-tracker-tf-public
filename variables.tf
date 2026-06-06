variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
}

variable "project_name" {
  description = "Used as a prefix for all resource names"
  type        = string
  default     = "incident-tracker"
}

variable "environment" {
  description = "e.g. dev, staging, prod"
  type        = string
  default     = "dev"
}

variable "alert_email" {
  description = "Email address to receive CloudWatch alarm notifications"
  type        = string
}