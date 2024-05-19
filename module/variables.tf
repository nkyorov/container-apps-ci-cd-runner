variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
  type        = string
}

variable "user_assigned_identity" {
  description = "Describes the UAMI that will authenticate to the ACR."
  type = object({
    name                 = string
    scope                = string
    role_definition_name = optional(string, "AcrPull")
  })
}

variable "container_app_environment" {
  description = "Describes the App Environment where the App Jobs will be placed."
  type = object({
    name = string
  })
}

variable "secrets" {
  description = "Describes the secrets that will be set in the container."
  type        = map(string)
}

variable "environment_variables" {
  description = "Describes the environment variables that will be set in the container."
  type        = map(string)
}

variable "container_registry_login_server" {
  description = "Describes the ACR's login server that stores the runner image."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Describes the log analytics workspace id, where logs will be stored."
  type        = string
}

variable "location" {
  description = "The Azure Region where the resources should exist."
  type        = string
  default     = "westeurope"
}

variable "container_app_job" {
  description = "Describes the App Job."
  type = object({
    name                       = string
    replica_timeout_in_seconds = optional(number, 1800)
    replica_retry_limit        = optional(number, 0)
  })
}

variable "event_trigger_config" {
  description = "Describes the event trigger config for the App Job."
  type = object({
    parallelism              = optional(number, 1)
    replica_completion_count = optional(number, 1)
    scale = object({
      min_executions              = optional(number, 0)
      max_executions              = optional(number, 10)
      polling_interval_in_seconds = optional(number, 30)
      rules = object({
        name             = optional(string, "github-runner")
        custom_rule_type = optional(string, "github-runner")
        metadata         = map(string)
        authentication = optional(object({
          secret_name       = optional(string, "personal-access-token")
          trigger_parameter = optional(string, "personalAccessToken")
        }), {})
      })
    })
  })
}

variable "container" {
  description = "Describes the container that will act as runner."
  type = object({
    image  = string
    name   = string
    cpu    = optional(number, 2.0)
    memory = optional(string, "4Gi")
  })
}
