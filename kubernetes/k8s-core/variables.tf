variable "branch" {
  description = "Git branch which to use for flux repo"
  type        = string
  default     = "master"
}

variable "cluster_id" {
  description = "Name of cluster in the flux repo"
  type        = string
}

variable "cluster_repo" {
  description = "Name of flux repo"
  type        = string
}

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

variable "github_owner" {
  description = "Owner of flux repo, used in coalition with cluster_repo to figure out github path"
  type        = string
}

variable "istio_version" {
  description = "Version of Istio, this will read the apropriate operator config within this repo"
  type        = string
}

variable "istio_control_plane_yaml" {
  description = "yaml content of istio control plane configuration"
  type        = string
}

variable "istio_gateways_yaml" {
  description = "yaml content of istio gateway configuration"
  type        = string
}
