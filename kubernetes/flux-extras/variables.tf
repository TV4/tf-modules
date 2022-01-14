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

variable "extra_repos" {
  description = "List of private github repos which should add the same deploy key."
  type        = list(string)
  default     = []
}

variable "github_owner" {
  description = "Owner of flux repo, used in coalition with cluster_repo to figure out github path"
  type        = string
}
