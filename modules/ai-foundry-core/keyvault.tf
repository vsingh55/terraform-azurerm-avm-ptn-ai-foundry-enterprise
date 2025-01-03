

variable "app_gateway_listener_certificate" {
  description = "The certificate data for app gateway TLS termination. The value is base64 encoded"
  type        = string
  default     = ""
}

// Assign Key Vault Access Policy
resource "azurerm_key_vault_access_policy" "key_vault_access_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id 

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Backup",
    "Restore",
    "Recover",
    "Purge"
  ]

  certificate_permissions = [
    "Get",
    "List"
  ]

  key_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_role_assignment" "key_vault_secrets_user" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

data "azurerm_client_config" "current" {}

variable "api_key" {
  description = "API key to store in Key Vault"
  type        = string
  sensitive   = true
  default     = ""
}

variable "create_private_endpoints" {
  description = "Determines whether to create private endpoints, DNS Zone, Zone Link, and Zone Group"
  type        = bool
  default     = true
}

// Key Vault Resource
resource "azurerm_key_vault" "key_vault" {
  name                     = "kv-${var.base_name}"
  location                 = var.location
  resource_group_name      = data.azurerm_resource_group.ai_resource_group.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  enable_rbac_authorization     = true
  enabled_for_deployment        = true
  enabled_for_template_deployment = true
  soft_delete_retention_days    = 7
}

// Key Vault Secrets
resource "azurerm_key_vault_secret" "gateway_public_cert" {
  name         = "gateway-public-cert"
  value        = var.app_gateway_listener_certificate
  content_type = "application/x-pkcs12"
  key_vault_id = azurerm_key_vault.key_vault.id
  depends_on   = [azurerm_key_vault.key_vault, azurerm_key_vault_access_policy.key_vault_access_policy, azurerm_role_assignment.key_vault_secrets_user]
}

resource "azurerm_key_vault_secret" "api_key" {
  name         = "apiKey"
  value        = var.api_key
  key_vault_id = azurerm_key_vault.key_vault.id
  depends_on   = [azurerm_key_vault.key_vault, azurerm_key_vault_access_policy.key_vault_access_policy, azurerm_role_assignment.key_vault_secrets_user]
}

// Conditional Private Endpoint Creation
resource "azurerm_private_endpoint" "key_vault_private_endpoint" {
  count               = var.create_private_endpoints ? 1 : 0
  name                = "pep-${azurerm_key_vault.key_vault.name}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.ai_resource_group.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "myConnection"
    private_connection_resource_id = azurerm_key_vault.key_vault.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

    private_dns_zone_group {
    name = "key-vault-dns-group"

    private_dns_zone_ids = concat(
      var.key_vault.private_dns_zone_ids, // Define this variable for existing custom Key Vault DNS zones if needed.
      
      // Conditional DNS Zone IDs
      var.key_vault.deploy_storage_private_dns ? [
        azurerm_private_dns_zone.key_vault_dns_zone[0].id,
      ] : []
    )
  }

  depends_on = [azurerm_key_vault_secret.gateway_public_cert, azurerm_key_vault_secret.api_key]
}

