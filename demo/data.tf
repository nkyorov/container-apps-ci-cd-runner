data "azurerm_container_registry" "aca_gh_runners" {
  name                = var.container_registry.name
  resource_group_name = var.container_registry.resource_group_name
}

data "azurerm_log_analytics_workspace" "this" {
  name                = var.log_analytics_workspace.name
  resource_group_name = var.log_analytics_workspace.resource_group_name
}
