variable "subscription_id" { 
  description = "The subscription id"   
}
variable "eligible_roles" {
  type = map(string)
  default = {
    search_index_data_contributor             = "8ebe5a00-799e-43f5-93ac-243d3dce84a7"
    search_index_data_reader                  = "1407120a-92aa-4202-b7e9-c0e197c71c8f"
    search_service_contributor                = "7ca78c08-252a-4471-8644-bb5ff32d4ba0"
    storage_blob_data_contributor             = "ba92f5b4-2d11-453d-a403-e96b0029c9fe"
    storage_blob_data_privileged_contributor  = "69566ab7-960f-475b-8e7c-b3118f30c6bd"
    storage_blob_data_owner                   = "b7e6dc6d-f1e8-4753-8033-0f276bb0955b"
    cognitive_services_openai_contributor     = "a001fd3d-188f-4b5d-821b-7da978bf7442"
    cognitive_services_openai_user            = "5e0bd9bd-7b93-4f28-af87-19fc36ad61bd"
    ai_inference_deployment_operator          = "3afb7f49-54cb-416e-8c09-6dc049efa503"
    contributor                               = "b24988ac-6180-42a0-ab88-20f7382dd24c"
    reader                                    = "acdd72a7-3385-48ef-bd42-f606fba81ae7"
    key_vault_administrator                   = "00482a5a-887f-4fb3-b363-3b7fe8e74483"
    user_access_administrator                 = "18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
    owner                                     = "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
    storage_file_data_privileged_contributor  = "69566ab7-960f-475b-8e7c-b3118f30c6bd"
    storage_file_data_smb_share_contributor   = "0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb"
    azure_ai_developer                        = "64702f94-c441-49e6-a78b-ef80e0188fee"
    azure_ai_administrator                    = "b78c5d69-af96-48a3-bf8d-a8b4d589de94"
  }
}

variable "role_templates" {
  type = map(list(object({
    role_name      = string
    scope = string
  })))
  default = {
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
      { role_name = "azure_ai_administrator", scope = "resource_group_id" },
      { role_name = "owner", scope = "ai_hub_id" },
      { role_name = "search_index_data_contributor", scope = "ai_search_service_id" },
      { role_name = "search_service_contributor", scope = "ai_search_service_id" },
      { role_name = "cognitive_services_openai_contributor", scope = "openai_chat_id" },
      { role_name = "cognitive_services_openai_user", scope = "openai_embedding_id" },
      { role_name = "storage_blob_data_contributor", scope = "storage_account_id" },
      { role_name = "storage_file_data_privileged_contributor", scope = "storage_account_id" }
    ]
  }
}

variable "managed_identity_roles" {
  description = "Roles assigned to managed identities"
  type = list(object({
    role_name      = string
    scope = string
    object_id      = string
  }))
}


variable "group_assignments" {
  type = map(list(object({
    type      = string
    objectid  = string
    name      = string
  })))
  default = {
    infra_admin = [
      { type = "user", objectid = "", name = "Admin User" }
    ]
    ai_admin = [
      { type = "user", objectid = "", name = "AI Admin User" }
    ]
    managed_identity = [
      { type = "managed_identity", objectid = "", name = "Managed Identity" }
    ]
  }
}

variable "scopes" {
  type = map(string)
  default = {
    resource_group_id    = "actual_resource_group_id"
    ai_search_service_id = "actual_ai_search_service_id"
    ai_hub_id            = "actual_ai_hub_id"
    openai_chat_id       = "actual_openai_chat_id"
    openai_embedding_id  = "actual_openai_embedding_id"
    storage_account_id   = "actual_storage_account_id"
  }
}
