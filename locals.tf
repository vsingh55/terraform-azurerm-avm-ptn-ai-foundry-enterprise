locals {
    managed_identity_roles = [
        { role_name = "search_index_data_reader", scope = "ai_search_service_id", object_id = module.ai_foundry_services[0].aiServicesPrincipalId },
        { role_name = "search_index_data_contributor", scope = "ai_search_service_id", object_id = module.ai_foundry_services[0].aiServicesPrincipalId },
        { role_name = "search_service_contributor", scope = "ai_search_service_id", object_id = module.ai_foundry_services[0].aiServicesPrincipalId },
        { role_name = "storage_blob_data_contributor", scope = "storage_account_id", object_id = module.ai_foundry_services[0].aiServicesPrincipalId },
        { role_name = "storage_blob_data_owner", scope = "storage_account_id", object_id = module.ai_foundry_services[0].aiServicesPrincipalId },
        { role_name = "cognitive_services_openai_contributor", scope = "openai_chat_id", object_id = module.ai_foundry_services[0].aiServicesPrincipalId },
        { role_name = "ai_inference_deployment_operator", scope = "resource_group_id", object_id = module.ai_foundry_services[0].aiServicesPrincipalId },
        { role_name = "storage_file_data_privileged_contributor", scope = "storage_account_id", object_id = module.ai_foundry_services[0].aiServicesPrincipalId },
        { role_name = "key_vault_administrator", scope = "resource_group_id", object_id = module.ai_foundry_services[0].aiServicesPrincipalId },
        { role_name = "user_access_administrator", scope = "resource_group_id", object_id = module.ai_foundry_services[0].aiServicesPrincipalId }
    ]

    eligible_roles   = {
    search_index_data_contributor            = "8ebe5a00-799e-43f5-93ac-243d3dce84a7"
    search_index_data_reader                 = "1407120a-92aa-4202-b7e9-c0e197c71c8f"
    search_service_contributor               = "7ca78c08-252a-4471-8644-bb5ff32d4ba0"
    storage_blob_data_contributor            = "ba92f5b4-2d11-453d-a403-e96b0029c9fe"
    storage_blob_data_privileged_contributor = "69566ab7-960f-475b-8e7c-b3118f30c6bd"
    storage_blob_data_owner                  = "b7e6dc6d-f1e8-4753-8033-0f276bb0955b"
    cognitive_services_openai_contributor    = "a001fd3d-188f-4b5d-821b-7da978bf7442"
    cognitive_services_openai_user           = "5e0bd9bd-7b93-4f28-af87-19fc36ad61bd"
    ai_inference_deployment_operator         = "3afb7f49-54cb-416e-8c09-6dc049efa503"
    contributor                              = "b24988ac-6180-42a0-ab88-20f7382dd24c"
    reader                                   = "acdd72a7-3385-48ef-bd42-f606fba81ae7"
    key_vault_administrator                  = "00482a5a-887f-4fb3-b363-3b7fe8e74483"
    user_access_administrator                = "18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
    owner                                    = "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
    storage_file_data_privileged_contributor = "69566ab7-960f-475b-8e7c-b3118f30c6bd"
    storage_file_data_smb_share_contributor  = "0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb"
    azure_ai_developer                       = "64702f94-c441-49e6-a78b-ef80e0188fee"
    azure_ai_administrator                   = "b78c5d69-af96-48a3-bf8d-a8b4d589de94"
  }
}

locals {
  base_shared_private_links = [
    {
      groupId               = "blob"
      status                = "Approved"
      provisioningState     = "Succeeded"
      requestMessage        = "created using the Bicep template"
      privateLinkResourceId = lookup(module.ai_foundry_core[0], "ml_storage_id", null)
    },
    {
      groupId               = "cognitiveservices_account"
      status                = "Approved"
      provisioningState     = "Succeeded"
      requestMessage        = "created using the Bicep template"
      privateLinkResourceId = lookup(module.ai_foundry_services[0], "aiServicesId", null)
    }
  ]

  base_ai_hub_outbound_rules = {
    search = {
      type = "PrivateEndpoint"
      destination = {
        serviceResourceId = lookup(module.ai_foundry_services[0], "search_service_id", null)
        subresourceTarget = "searchService"
        sparkEnabled      = false
        sparkStatus       = "Inactive"
      }
    }
    aiservices = {
      type = "PrivateEndpoint"
      destination = {
        serviceResourceId = lookup(module.ai_foundry_services[0], "aiServicesId", null)
        subresourceTarget = "account"
        sparkEnabled      = false
        sparkStatus       = "Inactive"
      }
    }
  }
}

locals {
  core_config = {
    acr = var.core_config.acr
    storage = var.core_config.storage
    key_vault = var.core_config.key_vault
    ai_hub = {
      private_dns_zone_ids = var.core_config.ai_hub.private_dns_zone_ids
      tags                 = var.tags
      deploy_private_dns   = var.core_config.ai_hub.deploy_private_dns
      description          = var.core_config.ai_hub.description
    }
  }
}


locals {
  group_assignments =var.group_assignments 
}
