variable "cluster_resource" {
  description = "Optional cluster resource to depend on"
  type = object({
    name = string
    arn  = string
  })
  default = {
    name = ""
    arn  = ""
  }
}

variable "external_dns_config" {
  description = "Role ARN for external-dns"
  type = object({
    role_arn = string
  })
  default = {
    role_arn = ""
  }
}
