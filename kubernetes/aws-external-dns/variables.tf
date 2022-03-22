variable "name" {
  description = "Cluster name"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "role_arn" {
  description = "Role ARN"
  type        = string
}

variable "zone_name" {
  description = "route53 zone name"
  type        = string
}

variable "zone_type" {
  description = "route53 zone type private/public"
  type        = string
  default     = "public"
}

variable "sources" {
  description = "optional sources to scan"
  type        = list(any)
  default     = ["service", "ingress", "istio-virtualservice", "istio-gateway"]
}
