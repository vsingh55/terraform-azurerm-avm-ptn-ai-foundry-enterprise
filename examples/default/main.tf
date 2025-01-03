provider "azurerm" {
  features {}
 
}

provider "azapi" {
 
}

terraform {
  required_version = ">= 1.3.4"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.11.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 2.2.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

resource "random_id" "short_name" {
  byte_length = 4
}

locals {
  development_environment = true
  base_name               = "${random_id.short_name.hex}${random_id.short_name.dec}"
  location                = "swedencentral"
  tags                    = { "Environment" = "development", "Owner" = "team" }

  search_config = {
    private_dns_zone_ids       = []
    tags                       = {}
    sku_name                   = "standard"
    disable_local_auth         = true
    hosting_mode               = "default"
    public_network_access      = "disabled"
    partition_count            = 1
    replica_count              = 1
    semantic_search            = "disabled"
    search_identity_provider   = { type = "None" }
    deploy_shared_private_link = true
    deploy_private_dns_zones   = true
  }

  network = {
    base_name                       = "network-base"
    development_environment         = local.development_environment
    vnet_address_prefix             = "10.0.0.0/16"
    app_gateway_subnet_prefix       = "10.0.1.0/24"
    private_endpoints_subnet_prefix = "10.0.2.0/27"
    agents_subnet_prefix            = "10.0.2.32/27"
    bastion_subnet_prefix           = "10.0.2.64/26"
    jumpbox_subnet_prefix           = "10.0.2.128/28"
    training_subnet_prefix          = "10.0.3.0/24"
    scoring_subnet_prefix           = "10.0.4.0/24"
    app_services_subnet_prefix      = "10.0.5.0/24"
  }

  aiservice_config = {
    private_dns_zone_ids     = []
    aiServiceSkuName         = "S0"
    base_name                = local.base_name
    disableLocalAuth         = false
    deploy_private_dns_zones = true
  }

  core_config = {
    acr = {
      private_dns_zone_ids   = []
      deploy_acr_private_dns = true
    }
    storage = {
      private_dns_zone_ids       = []
      deploy_storage_private_dns = true
    }
    key_vault = {
      private_dns_zone_ids       = []
      deploy_storage_private_dns = true
    }
    ai_hub = {
      private_dns_zone_ids = []
      tags                 = local.tags
      deploy_private_dns   = true
      description          = "AI Hub"
    }
  }
}

module "complete_infrastructure" {
  source = "../../"

  base_name               = local.base_name
  location                = local.location
  tags                    = local.tags
  development_environment = local.development_environment

  // use this collection to define the role templates for the different groups
  role_templates = {
    infra_admin = [
      { role_name = "contributor", scope = "resource_group_id" },
      { role_name = "azure_ai_administrator", scope = "resource_group_id" },
      { role_name = "search_index_data_contributor", scope = "ai_search_service_id" },
      { role_name = "cognitive_services_openai_user", scope = "openai_embedding_id" },
      { role_name = "cognitive_services_openai_contributor", scope = "openai_chat_id" },
      { role_name = "search_service_contributor", scope = "ai_search_service_id" },
      { role_name = "storage_blob_data_contributor", scope = "storage_account_id" },
      { role_name = "storage_file_data_privileged_contributor", scope = "storage_account_id" }
    ]
    ai_admin = [
      { role_name = "owner", scope = "ai_hub_id" },
      { role_name = "azure_ai_administrator", scope = "resource_group_id" },
      { role_name = "search_index_data_contributor", scope = "ai_search_service_id" },
      { role_name = "search_service_contributor", scope = "ai_search_service_id" },
      { role_name = "cognitive_services_openai_contributor", scope = "openai_chat_id" },
      { role_name = "cognitive_services_openai_user", scope = "openai_embedding_id" },
      { role_name = "storage_blob_data_contributor", scope = "storage_account_id" },
      { role_name = "storage_file_data_privileged_contributor", scope = "storage_account_id" }
    ]
  }

  // Use this collection to assign users to each one of the roles defined in the role_templates collection
  group_assignments = {
    infra_admin = [
      { type = "user", objectid = "a1234567-89ab-cdef-0123-456789abcdef", name = "Admin User" }
    ]
  }

  // Use this configuration to define which layer to deploy, you can also choose to deploy only an specific layer
  // Be aware that the layers are dependent on each other, so if you choose to deploy only one layer, 
  // you will need to provide the required information for the other layers
  deployment_config = {
    deploy_network  = true
    deploy_services = true
    deploy_core     = true
    deploy_identity = true
    deploy_shared   = true
  }

  // you can add extra shared private links to the shared resources module
  extra_shared_private_links = []
  // you can add extra outbound rules to the ai hub module
  extra_ai_hub_outbound_rules = {}
  // this is the configureation for the core, search and ai services
  search_config    = local.search_config
  aiservice_config = local.aiservice_config
  core_config      = local.core_config
}

