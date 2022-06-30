variable "certificate_arn" {
  type        = string
  description = "ARN of the ACM Certificate to be attached to ALB HTTPS Listener"
}

variable "min_containers" {
  description = "minimum containers count"
  type        = number
  default     = 2
}

variable "max_containers" {
  description = "maximum containers count"
  type        = number
  default     = 10
}

variable "auto_scaling_target_cpu_utilization" {
  type        = number
  default     = 75
  description = "Auto scaling cpu target"
}

variable "database_instance_type" {
  type        = string
  description = "Instance type to be used for the core instances"
  default     = "r5.large"
}

variable "database_instance_count" {
  type        = number
  default     = 2
  description = "Number of database instances"
}

variable "db_password_secret_arn" {
  type        = string
  description = "ARN of the Secrets Manager secret containing the database password"
}

variable "keycloak_password_secret_arn" {
  type        = string
  description = "ARN of the Secrets Manager secret containing the keycloak master password"
}

variable "keycloak_user" {
  type        = string
  description = "Username for the keycloak master user"
}

variable "tags" {
  description = "Map of tags to set for the created resources"
}

variable "db_deletion_protection" {
  type        = bool
  default     = true
  description = "Prevent the database from being accidentally deleted"
}

variable "secrets_manager_kms_key_alias" {
  type        = string
  description = "Alias for the key used to decrypt password secrets"
}

variable "vpc_id" {
  type        = string
  description = "Id if the VPC"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of subnet IDs"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of subnet IDs"
}

variable "keycloak_url" {
  type        = string
  description = "FQDN for this keycloak instance. Used for creating internal certificates"
}

variable "keycloak_verbose_logging" {
  type        = bool
  default     = false
  description = "Enables verbose logging for the keycloak instances"
}