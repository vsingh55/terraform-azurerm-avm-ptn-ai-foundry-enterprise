// Storage Account for App Deployment
resource "azurerm_storage_account" "app_deploy_storage" {
  name                          = "st${lower(var.base_name)}"
  location                      = var.location
  resource_group_name           = data.azurerm_resource_group.ai_resource_group.name
  account_tier                  = "Standard"
  account_replication_type      = "ZRS"
  account_kind                  = "StorageV2"
  access_tier                   = "Hot"
  https_traffic_only_enabled    = true
  public_network_access_enabled = false
  min_tls_version               = "TLS1_2"

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [var.private_endpoint_subnet_id]
    ip_rules                   = []
    bypass                     = ["AzureServices"]
  }

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
}

// Private Endpoints for App Storage
resource "azurerm_private_endpoint" "app_deploy_storage_private_endpoint" {
  name                = "pep-${azurerm_storage_account.app_deploy_storage.name}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.ai_resource_group.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "blobConnection"
    private_connection_resource_id = azurerm_storage_account.app_deploy_storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

// Storage Account for Machine Learning
resource "azurerm_storage_account" "ml_storage" {
  name                          = "stml${lower(var.base_name)}"
  location                      = var.location
  resource_group_name           = data.azurerm_resource_group.ai_resource_group.name
  account_tier                  = "Standard"
  account_replication_type      = "ZRS"
  account_kind                  = "StorageV2"
  access_tier                   = "Hot"
  https_traffic_only_enabled    = true
  public_network_access_enabled = false
  min_tls_version               = "TLS1_2"

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [var.private_endpoint_subnet_id]
    ip_rules                   = []
    bypass                     = ["AzureServices"]
  }

  lifecycle {
    ignore_changes = [
      network_rules[0].private_link_access
    ]
  }
}

// Private Endpoints for Machine Learning Blob
resource "azurerm_private_endpoint" "ml_blob_storage_private_endpoint" {
  name                = "pep-blob-${azurerm_storage_account.ml_storage.name}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.ai_resource_group.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "blobConnection"
    private_connection_resource_id = azurerm_storage_account.ml_storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

// Private Endpoints for Machine Learning File
resource "azurerm_private_endpoint" "ml_file_storage_private_endpoint" {
  name                = "pep-file-${azurerm_storage_account.ml_storage.name}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.ai_resource_group.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "fileConnection"
    private_connection_resource_id = azurerm_storage_account.ml_storage.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }

  private_dns_zone_group {
    name = "storage-dns-group"

    private_dns_zone_ids = concat(
      var.storage.private_dns_zone_ids, // Define this variable for existing custom Key Vault DNS zones if needed.
      
      // Conditional DNS Zone IDs
      var.storage.deploy_storage_private_dns ? [
        azurerm_private_dns_zone.blob_dns_zone[0].id, // If needed
        azurerm_private_dns_zone.file_dns_zone[0].id  // If needed
      ] : []
    )
  }
}
// Outputs
output "app_deploy_storage_name" {
  description = "The name of the App Deployment Storage Account"
  value       = azurerm_storage_account.app_deploy_storage.name
}

output "ml_storage_name" {
  description = "The name of the Machine Learning Storage Account"
  value       = azurerm_storage_account.ml_storage.name
}

output "app_deploy_storage_id" {
  description = "The ID of the App Deployment Storage Account"
  value       = azurerm_storage_account.app_deploy_storage.id
}

output "ml_storage_id" {
  description = "The ID of the Machine Learning Storage Account"
  value       = azurerm_storage_account.ml_storage.id
}
