variable "location" {
  description = "The Azure Region where the resources should exist."
  type        = string
  default     = "westeurope"
}

variable "suffix" {
  description = "Suffix to append to all resources."
  type        = string
  default     = "aca-gh-runners"
}

variable "personal_access_token" {
  description = "GitHub PAT."
  type        = string
  sensitive   = true
}

variable "container_registry" {
  description = "Describes the container registry that will store the runner's image."
  type = object({
    name                = string
    resource_group_name = string
    image_name_with_tag = string
  })
}

variable "log_analytics_workspace" {
  description = "Describes the log analytics workspace, where logs will be stored."
  type = object({
    name                = string
    resource_group_name = string
  })
}

variable "github_config" {
  description = "Describes the details of the repository that will be able to use the runners."
  type = object({
    owner = string
    repo  = string
  })
}
