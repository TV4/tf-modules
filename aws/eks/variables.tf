variable "name" {
  description = "Cluster identification string"
  type        = string
}

variable "eks_version" {
  description = "EKS k8s version"
  type        = string
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
}

variable "vpc" {
  description = "VPC which EKS cluster resides in"
  type        = string
}

variable "subnets" {
  description = "All subnets which nodes can be in"
  type        = list(string)
}

variable "roles" {
  description = "Access rights, derived from roles"
  type = list(object({
    groups   = list(string)
    rolearn  = string
    username = string
  }))
  default = []
}

variable "users" {
  description = "Access rights, derived from roles"
  type = list(object({
    groups   = list(string)
    userarn  = string
    username = string
  }))
  default = []
}

variable "accounts" {
  description = "Access rights, derived from roles"
  type        = list(string)
  default     = []
}

variable "node_groups" {
  description = "List of Node worker groups"
}

