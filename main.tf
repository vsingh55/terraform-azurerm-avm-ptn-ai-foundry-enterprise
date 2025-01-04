// Resource group setup, always necessary
resource "azurerm_resource_group" "rg" {
  count    = var.use_existing_rg ? 0 : 1
  name     = var.use_existing_rg ? var.existing_rg_name : "${var.base_name}-rg"
  location = var.location
  tags     = merge({ SecurityControl = "Ignore" }, var.tags)
}

data "azurerm_client_config" "current" {}
data "azurerm_resource_group" "existing_rg" {
  count = var.use_existing_rg ? 1 : 0
  name  = var.existing_rg_name
}

module "ai_foundry_network" {
  count  = var.deployment_config.deploy_network ? 1 : 0
  source = "./modules/ai-foundry-network" # Ensure the path is relative to your main configuration file

  # Pass in all required variables. Ensure these match with your defined variables in the module.
  resource_group_name = var.use_existing_rg ? data.azurerm_resource_group.existing_rg[0].name : azurerm_resource_group.rg[0].name
  deploy_network      = var.deployment_config.deploy_network
  network             = merge(var.network, { location = var.location })
  config              = var.jumpbox_config
  base_name           = var.base_name
  location            = var.location
}

// Conditionally deploy ai-foundry-services module
module "ai_foundry_services" {
  source = "./modules/ai-foundry-services"

  count                      = var.deployment_config.deploy_services ? 1 : 0
  base_name                  = var.base_name
  location                   = var.location
  resource_group_name        = var.use_existing_rg ? data.azurerm_resource_group.existing_rg[0].name : azurerm_resource_group.rg[0].name
  resource_group_id          = var.use_existing_rg ? data.azurerm_resource_group.existing_rg[0].id : azurerm_resource_group.rg[0].id
  private_endpoint_subnet_id = var.existing_subnet_id != null ? var.existing_subnet_id : module.ai_foundry_network[0].private_endpoints_subnet_id
  vnet_id                    = var.existing_vnet_id != null ? var.existing_vnet_id : module.ai_foundry_network[0].vnet_id

  search    = var.search_config
  aiservice = var.aiservice_config
}

// Conditionally deploy ai-foundry-core module
module "ai_foundry_core" {
  source = "./modules/ai-foundry-core"

  count                      = var.deployment_config.deploy_core ? 1 : 0
  base_name                  = var.base_name
  location                   = var.location
  resource_group_id          = var.use_existing_rg ? data.azurerm_resource_group.existing_rg[0].id : azurerm_resource_group.rg[0].id
  private_endpoint_subnet_id = var.existing_subnet_id != null ? var.existing_subnet_id : module.ai_foundry_network[0].private_endpoints_subnet_id
  vnet_id                    = var.existing_vnet_id != null ? var.existing_vnet_id : module.ai_foundry_network[0].vnet_id

  acr       = local.core_config.acr
  storage   = local.core_config.storage
  key_vault = local.core_config.key_vault
  ai_hub    = local.core_config.ai_hub
}

// Conditionally deploy ai-foundry-identity module
module "ai_foundry_identity" {
  source = "./modules/ai-foundry-identity"

  count                  = var.deployment_config.deploy_identity ? 1 : 0
  subscription_id        = data.azurerm_client_config.current.subscription_id
  eligible_roles         = local.eligible_roles
  role_templates         = var.role_templates
  managed_identity_roles = local.managed_identity_roles
  group_assignments      = local.group_assignments

  scopes = {
    resource_group_id    = var.use_existing_rg ? data.azurerm_resource_group.existing_rg[0].id : azurerm_resource_group.rg[0].id
    ai_search_service_id = lookup(module.ai_foundry_services[0], "search_service_id", null)
    ai_hub_id            = lookup(module.ai_foundry_core[0], "ai_hub_id", null)
    openai_chat_id       = lookup(module.ai_foundry_services[0], "aiServicesId", null)
    openai_embedding_id  = lookup(module.ai_foundry_services[0], "aiServicesId", null)
    storage_account_id   = lookup(module.ai_foundry_core[0], "ml_storage_id", null)
  }
}

// Conditionally deploy ai-foundry-shared-resources module
module "ai_foundry_shared" {
  source = "./modules/ai-foundry-shared-resources"

  count = var.deployment_config.deploy_shared ? 1 : 0
  shared_private_link = {
    os_type                    = "windows"
    target_service_id          = lookup(module.ai_foundry_services[0], "search_service_id", null)
    deploy_shared_private_link = true
    shared_private_links       = concat(local.base_shared_private_links, var.extra_shared_private_links)
  }
  ai_hub_id             = lookup(module.ai_foundry_core[0], "ai_hub_id", null)
  ai_hub_outbound_rules = merge(local.base_ai_hub_outbound_rules, var.extra_ai_hub_outbound_rules)
}

// Outputs
output "ai_foundry_network_outputs" {
  value = module.ai_foundry_network
  description = "Outputs from the ai_foundry_network module"
}

output "ai_foundry_services_outputs" {
  value = module.ai_foundry_services
  description = "Outputs from the ai_foundry_services module"
}

output "ai_foundry_core_outputs" {
  value = module.ai_foundry_core
  description = "Outputs from the ai_foundry_core module"
}

output "ai_foundry_identity_outputs" {
  value = module.ai_foundry_identity
  description = "Outputs from the ai_foundry_identity module"
}

output "ai_foundry_shared_outputs" {
  value = module.ai_foundry_shared
  description = "Outputs from the ai_foundry_shared module"
}
