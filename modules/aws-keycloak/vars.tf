variable "certificate_arn" {
  type = string
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
  type    = number
  default = 75
}

variable "database_instance_type" {
  type        = string
  description = "Instance type to be used for the core instances"
  default     = "r5.large"
}

variable "database_instance_count" {
  type    = number
  default = 2
}

variable "db_password_secret_arn" {
  type = string
}

variable "keycloak_password_secret_arn" {
  type = string
}

variable "keycloak_user" {
  type = string
}

variable "tags" {
}

variable "db_deletion_protection" {
  type    = bool
  default = true
}

variable "secrets_manager_kms_key_alias" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "keycloak_url" {
  type = string
}

variable "keycloak_verbose_logging" {
  type    = bool
  default = false
}