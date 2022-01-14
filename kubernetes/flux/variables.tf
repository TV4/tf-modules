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

variable "flux_repo_path" {
  description = "Default path to store clusters"
  type        = string
  default     = "clusters"
}

variable "registry_flux" {
  description = "Artifact registry to pull images from for flux"
  type        = string
  default     = "ghcr.io/fluxcd"
}

variable "github_owner" {
  description = "Owner of flux repo, used in coalition with cluster_repo to figure out github path"
  type        = string
}

