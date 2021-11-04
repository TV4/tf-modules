variable "role_arn" {
  description = "Role ARN"
  type        = string
}

variable "name" {
  description = "Service account name"
  type        = string
}

variable "namespace" {
  description = "Namespace for service account"
  type        = string
  default     = "default"
}
