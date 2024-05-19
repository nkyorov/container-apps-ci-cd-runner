module "naming" {
  source = "Azure/naming/azurerm"
  suffix = [var.suffix]
}

module "runner" {
  source = "../module"

  log_analytics_workspace_id      = data.azurerm_log_analytics_workspace.this.id
  resource_group_name             = module.naming.resource_group.name
  container_registry_login_server = data.azurerm_container_registry.aca_gh_runners.login_server

  container_app_environment = {
    name = module.naming.container_app_environment.name
  }

  user_assigned_identity = {
    name  = module.naming.user_assigned_identity.name
    scope = data.azurerm_container_registry.aca_gh_runners.id
  }

  secrets = {
    "personal-access-token" = var.personal_access_token
  }

  environment_variables = local.environment_variables

  container_app_job = local.container_app_job
  container         = local.container

  event_trigger_config = {
    scale = {
      rules = {
        metadata = local.metadata
      }
    }
  }
}
