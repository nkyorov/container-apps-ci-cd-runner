# Self-hosted CI/CD runners in Azure Container Apps jobs
*This repository is Terraform implementation of the following Microsoft Tutorial: [Deploy self-hosted CI/CD runners and agents with Azure Container Apps jobs](https://learn.microsoft.com/en-us/azure/container-apps/tutorial-ci-cd-runners-jobs?tabs=bash&pivots=container-apps-jobs-self-hosted-ci-cd-github-actions)*

## Overview

Self-hosted runners are useful when you need to run workflows that require access to local resources or tools that aren't available to a cloud-hosted runner.

Running self-hosted runners as event-driven jobs allows you to take advantage of the serverless nature of Azure Container Apps. Jobs execute automatically when a workflow is triggered and exit when the job completes.

> [!NOTE]
> Self-hosted runners are only recommended for private repositories. Using them with public repositories can allow dangerous code to execute on your self-hosted runner.

## Prerequsites
Before you begin, ensure you have the following prerequisites in place:

1. **Log Analytics Workspace**: Ensure you have a configured Log Analytics Workspace in Azure.
2. **Azure Container Registry**: Have an Azure Container Registry set up to store the images for the runners.
3. **Personal Access Token**:  Each time a runner starts, the PAT is used to generate a token to register the runner with GitHub. The PAT is also used by the GitHub Actions runner scale rule to monitor the repository's workflow queue and start runners as needed.


    | Setting | Value |
    |---|---|
    | Actions | Select **Read-only**. |
    | Administration | Select **Read and write**. |
    | Metadata | Select **Read-only**. |

> [!TIP]
> You can also use a GitHub App if you are working in the context of an organization

> [!NOTE]
> Terraform will create and assign User Assigned Managed Identity with `AcrPull` on the Azure Container Registry.

## Demo
### Build an image based on the Github Runner
You can use the `Dockerfile.github` provided as part of this repository to build your own image based on the GitHub runner and push it to your Azure Container registry.

```bash
CONTAINER_IMAGE_NAME="github-actions-runner:<IMAGE_TAG>"
CONTAINER_REGISTRY_NAME="<CONTAINER_REGISTRY_NAME>"

az acr build \
    --registry "$CONTAINER_REGISTRY_NAME" \
    --image "$CONTAINER_IMAGE_NAME" \
    --file "Dockerfile.github"
```

###  Clone the repo and setup your variables
1. Clone this repository to your local machine.
2. Open the repo in Visual Studio Code. (Hint: In a terminal you can open Visual Studio Code by navigating to the folder and running code .).
3. Navigate to the `demo` folder and create a new file called `terraform.tfvars`.
4. In the `terraform.tfvars`` file add the following:
```hcl
 personal_access_token = "<value>"
 container_registry = {
   name                = "<value>"
   resource_group_name = "<value>"
   image_name_with_tag = "<value>"
 }
 log_analytics_workspace = {
   name                = "<value>"
   resource_group_name = "<value>"
 }
 github_config = {
   owner = "<value>"
   repo  = "<value>"
 }
```

### Apply the Terraform
1. Open the Visual Studio Code Terminal and navigate the `demo` folder.
2. Run `az login` and follow the prompts to login to Azure with your Global Administrator account.
3. Run `az account show`. If you are not connected to you test subscription, change it by running `az account set --subscription "<subscription-id>"`
4. Run `terraform init`.
5. Run `terraform apply`.
6. The plan will complete. Review the plan and see what is going to be created.
7. Type `yes` and hit enter once you have reviewed the plan.
8. Wait for the apply to complete.


> [!NOTE]
> In your workflow file use `runs-on: self-hosted` so that jobs will be scheduled on the containers.

## Wrapping it all up
This setup is not intended for production use and does not include the following considerations:

- **Private Endpoints**: Configure private endpoints to securely connect the CI/CD runners to internal resources
- **Azure Key Vault**: Use Azure Key Vault to securely store and access secrets
- **Runner Groups**: Organize your runners into groups to improve management
- **Performance**: Default scaling rules are cost-effective, meaning most of the time is spend on spinning a new instance for each job
