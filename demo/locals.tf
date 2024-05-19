locals {
  environment_variables = {
    "GITHUB_PAT"                 = "secretref:personal-access-token"
    "GH_URL"                     = "https://github.com/${var.github_config.owner}/${var.github_config.repo}"
    "REGISTRATION_TOKEN_API_URL" = "https://api.github.com/repos/${var.github_config.owner}/${var.github_config.repo}/actions/runners/registration-token"
  }
  metadata = {
    "githubAPIURL"              = "https://api.github.com"
    "owner"                     = var.github_config.owner
    "runnerScope"               = "repo"
    "repos"                     = var.github_config.repo
    "targetWorkflowQueueLength" = "1"
  }
  container_app_job = {
    name = module.naming.container_app_environment.name
  }
  container = {
    name  = "github-actions-runner"
    image = "${data.azurerm_container_registry.aca_gh_runners.login_server}/${var.container_registry.image_name_with_tag}"
  }
}
