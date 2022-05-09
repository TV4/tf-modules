variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_1_cidr_block" {
  type    = string
  default = "10.0.0.0/18"
}

variable "public_subnet_2_cidr_block" {
  type    = string
  default = "10.0.64.0/18"
}

variable "private_subnet_1_cidr_block" {
  type    = string
  default = "10.0.128.0/18"
}

variable "private_subnet_2_cidr_block" {
  type    = string
  default = "10.0.192.0/18"
}

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

variable "java_opts" {
  type        = string
  description = "JAVA_OPTS environment variable"
}

variable "database_instance_type" {
  type        = string
  description = "Instance type to be used for the core instances"
  default     = "r5.large"
}

variable "db_password" {
  type = string
}

variable "keycloak_password" {
  type = string
}

variable "keycloak_user" {
  type = string
}

variable "tags" {
  type = object({})
}

