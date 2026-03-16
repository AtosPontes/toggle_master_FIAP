variable "project_name" {
  type        = string
  description = "Project name"
}

variable "tags" {
  type        = map(any)
  description = "Tags to be added to resources"
}

variable "db_user" {
  type        = string
  description = "RDS Postgres user"
}

variable "db_password" {
  type        = string
  description = "RDS Postgres password"
  sensitive   = true
}

variable "db_auth_endpoint" {
  type        = string
  description = "Auth DB endpoint"
}

variable "db_flag_endpoint" {
  type        = string
  description = "Flag DB endpoint"
}

variable "db_targeting_endpoint" {
  type        = string
  description = "Targeting DB endpoint"
}

variable "evaluation_db_endpoint" {
  type        = string
  description = "Redis endpoint"
}

variable "sqs_queue_url" {
  type        = string
  description = "SQS queue URL"
}

variable "dynamodb_url" {
  type        = string
  description = "DynamoDB table name"
}

variable "service_api_key" {
  type        = string
  description = "Service API key used by internal services"
  sensitive   = true
}
