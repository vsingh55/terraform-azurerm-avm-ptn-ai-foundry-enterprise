resource "random_pet" "rg_name" {
  prefix = var.base_name
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

data "azurerm_resource_group" "ai_resource_group" {
  name = split("/", var.resource_group_id)[4]
}

// AI Studio Hub
resource "azapi_resource" "ai_hub" {
  type      = "Microsoft.MachineLearningServices/workspaces@2024-07-01-preview"
  name      = "aihub-${var.base_name}"
  location  = var.location
  parent_id = var.resource_group_id

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      friendlyName             = "mlw-${var.base_name}"
      description              = var.ai_hub.description
      containerRegistry        = azurerm_container_registry.acr.id
      keyVault                 = azurerm_key_vault.key_vault.id
      storageAccount           = azurerm_storage_account.ml_storage.id
      systemDatastoresAuthMode = "identity"
      publicNetworkAccess      = "Disabled"

      managedNetwork = {
        isolationMode = "AllowInternetOutBound"
        outboundRules = {
          /*search = {
            type = "PrivateEndpoint"
            destination = {
              serviceResourceId = var.search_service_id
              subresourceTarget = "searchService"
              sparkEnabled      = false
              sparkStatus       = "Inactive"
            }
          },
          aiservices = {
            type = "PrivateEndpoint"
            destination = {
              serviceResourceId = var.ai_services_id
              subresourceTarget = "account"
              sparkEnabled      = false
              sparkStatus       = "Inactive"
            }
          },*/
        }
      }
    }
    kind = "hub"
  }

  tags = var.ai_hub.tags

  lifecycle {
    ignore_changes = [
      tags,
      output
    ]
  }
}

// Azure AI Project
resource "azapi_resource" "project" {
  type      = "Microsoft.MachineLearningServices/workspaces@2024-04-01-preview"
  name      = "my-ai-project${var.base_name}"
  location  = var.location
  parent_id = var.resource_group_id

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      description   = "This is my Azure AI PROJECT"
      friendlyName  = "My Project"
      hubResourceId = azapi_resource.ai_hub.id
    }
    kind = "project"
  }
}

// Private Endpoint for Machine Learning Workspace
resource "azurerm_private_endpoint" "ml_private_endpoint" {
  name                = "pep-${azapi_resource.ai_hub.name}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.ai_resource_group.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "amlworkspace-connection"
    private_connection_resource_id = azapi_resource.ai_hub.id
    subresource_names              = ["amlworkspace"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "aml-dns-group"

    private_dns_zone_ids = concat(
      var.ai_hub.private_dns_zone_ids, // Define this variable for existing custom zone IDs if needed.

      // Conditional DNS Zone IDs
      var.ai_hub.deploy_private_dns ? [

        azurerm_private_dns_zone.aml_private_dns[0].id,
        azurerm_private_dns_zone.notebook_private_dns[0].id,
      ] : []
    )
  }

  tags = { "environment" = "production" }
}

// Role Assignments for ACR Push/Pull
resource "azurerm_role_assignment" "acr_push_role_assignment" {
  principal_id         = azapi_resource.ai_hub.identity[0].principal_id
  role_definition_name = "AcrPush"
  scope                = azurerm_container_registry.acr.id
}

resource "azurerm_role_assignment" "acr_pull_role_assignment" {
  principal_id         = azapi_resource.ai_hub.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}

data "azurerm_resource_group" "example" {
  name = split("/", var.resource_group_id)[4]
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = data.azurerm_resource_group.example.name
}

// Output the unique workspace ID
output "ml_workspace_unique_id" {
  description = "The unique ID of the Azure ML Workspace"
  value       = azapi_resource.ai_hub.output.properties.workspaceId
}

output "ai_hub_id" {
  description = "The ID of the AI Hub"
  value       = azapi_resource.ai_hub.id
}

// Outputs for each resource
output "random_pet_rg_name" {
  description = "The random pet resource group name"
  value       = random_pet.rg_name.id
}

output "random_string_suffix" {
  description = "The random string suffix"
  value       = random_string.suffix.result
}

output "ai_project_id" {
  description = "The ID of the AI Project"
  value       = azapi_resource.project.id
}

output "ml_private_endpoint_id" {
  description = "The ID of the ML Private Endpoint"
  value       = azurerm_private_endpoint.ml_private_endpoint.id
}

output "acr_push_role_assignment_id" {
  description = "The ID of the ACR Push Role Assignment"
  value       = azurerm_role_assignment.acr_push_role_assignment.id
}

output "acr_pull_role_assignment_id" {
  description = "The ID of the ACR Pull Role Assignment"
  value       = azurerm_role_assignment.acr_pull_role_assignment.id
}

// Output all properties of AI Hub
output "ai_hub_properties" {
  description = "All properties of the AI Hub"
  value       = azapi_resource.ai_hub.output.properties
}

// Output all properties of AI Project
output "ai_project_properties" {
  description = "All properties of the AI Project"
  value       = azapi_resource.project.output.properties
}

// Output all properties of ML Private Endpoint
output "ml_private_endpoint_properties" {
  description = "All properties of the ML Private Endpoint"
  value       = azurerm_private_endpoint.ml_private_endpoint
}

// Output all properties of ACR Push Role Assignment
output "acr_push_role_assignment_properties" {
  description = "All properties of the ACR Push Role Assignment"
  value       = azurerm_role_assignment.acr_push_role_assignment
}