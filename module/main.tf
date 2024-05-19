resource "azurerm_resource_group" "aca_gh_runners" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_user_assigned_identity" "aca_gh_runners" {
  location            = azurerm_resource_group.aca_gh_runners.location
  name                = var.user_assigned_identity.name
  resource_group_name = azurerm_resource_group.aca_gh_runners.name
}

resource "azurerm_role_assignment" "aca_gh_runners" {
  scope                = var.user_assigned_identity.scope
  role_definition_name = var.user_assigned_identity.role_definition_name
  principal_id         = azurerm_user_assigned_identity.aca_gh_runners.principal_id
}

resource "azurerm_container_app_environment" "aca_gh_runners" {
  name                       = var.container_app_environment.name
  location                   = azurerm_resource_group.aca_gh_runners.location
  resource_group_name        = azurerm_resource_group.aca_gh_runners.name
  log_analytics_workspace_id = var.log_analytics_workspace_id
}

resource "azurerm_container_app_job" "aca_gh_runners" {
  name                         = var.container_app_job.name
  location                     = var.location
  resource_group_name          = azurerm_resource_group.aca_gh_runners.name
  container_app_environment_id = azurerm_container_app_environment.aca_gh_runners.id

  replica_timeout_in_seconds = var.container_app_job.replica_timeout_in_seconds
  replica_retry_limit        = var.container_app_job.replica_retry_limit

  event_trigger_config {
    parallelism              = var.event_trigger_config.parallelism
    replica_completion_count = var.event_trigger_config.replica_completion_count
    scale {
      min_executions              = var.event_trigger_config.scale.min_executions
      max_executions              = var.event_trigger_config.scale.max_executions
      polling_interval_in_seconds = var.event_trigger_config.scale.polling_interval_in_seconds

      rules {
        name             = var.event_trigger_config.scale.rules.name
        custom_rule_type = var.event_trigger_config.scale.rules.custom_rule_type
        metadata         = var.event_trigger_config.scale.rules.metadata
        authentication {
          secret_name       = var.event_trigger_config.scale.rules.authentication.secret_name
          trigger_parameter = var.event_trigger_config.scale.rules.authentication.trigger_parameter
        }
      }
    }
  }

  template {
    container {
      image  = var.container.image
      name   = var.container.name
      cpu    = var.container.cpu
      memory = var.container.memory

      dynamic "env" {
        for_each = var.environment_variables
        content {
          name        = env.key
          value       = startswith(env.value, "secretref") ? null : env.value
          secret_name = startswith(env.value, "secretref") ? split(":", env.value)[1] : null
        }
      }
    }
  }

  dynamic "secrets" {
    for_each = var.secrets
    content {
      name  = secrets.key
      value = secrets.value
    }
  }

  registries {
    server   = var.container_registry_login_server
    identity = azurerm_user_assigned_identity.aca_gh_runners.id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca_gh_runners.id]
  }
}
