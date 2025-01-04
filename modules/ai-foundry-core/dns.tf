
// Conditional DNS Zone Creation
resource "azurerm_private_dns_zone" "acr_dns_zone" {
  count                = var.acr.deploy_acr_private_dns ? 1 : 0
  name                 = "privatelink.azurecr.io"
  resource_group_name  = data.azurerm_resource_group.ai_resource_group.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr_dns_zone_link" {
  count                 = var.acr.deploy_acr_private_dns ? 1 : 0
  name                  = "${azurerm_private_dns_zone.acr_dns_zone[count.index].name}-link"
  resource_group_name   = data.azurerm_resource_group.ai_resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.acr_dns_zone[count.index].name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone" "aml_private_dns" {
  count               = var.ai_hub.deploy_private_dns ? 1 : 0
  name                = "privatelink.api.azureml.ms"
  resource_group_name = data.azurerm_resource_group.ai_resource_group.name
}

resource "azurerm_private_dns_zone" "notebook_private_dns" {
  count               = var.ai_hub.deploy_private_dns ? 1 : 0
  name                = "privatelink.notebooks.azure.net"
  resource_group_name = data.azurerm_resource_group.ai_resource_group.name
}
/*
resource "azurerm_private_dns_a_record" "acr_dns_a_record" {
  count                = var.acr.deploy_acr_private_dns ? 1 : 0
  name                 = azurerm_container_registry.acr.login_server
  zone_name            = azurerm_private_dns_zone.acr_dns_zone[count.index].name
  resource_group_name  = data.azurerm_resource_group.ai_resource_group.name
  ttl                  = 300
  records              = [azurerm_private_endpoint.acr_private_endpoint[count.index].private_service_connection[0].private_ip_address]
}




resource "azurerm_private_dns_a_record" "workspace_fqdn" {
  count               = var.ai_hub.deploy_private_dns ? 1 : 0
  name                = "${azapi_resource.ai_hub.output.properties.workspaceId}.workspace.${var.location}"
  zone_name           = azurerm_private_dns_zone.aml_private_dns[count.index].name
  resource_group_name = data.azurerm_resource_group.ai_resource_group.name
  ttl                 = 300
  records             =  [azurerm_private_endpoint.ml_private_endpoint.custom_dns_configs[0].ip_addresses[0]]
  lifecycle {
    ignore_changes = [
      name
    ]
  }
}

resource "azurerm_private_dns_a_record" "workspace_cert_fqdn" {
  count               = var.ai_hub.deploy_private_dns ? 1 : 0
  name                = "${azapi_resource.ai_hub.output.properties.workspaceId}.workspace.${var.location}.cert"
  zone_name           = azurerm_private_dns_zone.aml_private_dns[count.index].name
  resource_group_name = data.azurerm_resource_group.ai_resource_group.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.ml_private_endpoint.custom_dns_configs[0].ip_addresses[0]]
  lifecycle {
    ignore_changes = [
      name
    ]
  }
}

resource "azurerm_private_dns_a_record" "models_fqdn" {
  count               = var.ai_hub.deploy_private_dns ? 1 : 0
  name                = "*.${azapi_resource.ai_hub.output.properties.workspaceId}.models.${var.location}"
  zone_name           = azurerm_private_dns_zone.aml_private_dns[count.index].name
  resource_group_name = data.azurerm_resource_group.ai_resource_group.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.ml_private_endpoint.custom_dns_configs[3].ip_addresses[0]]
  lifecycle {
    ignore_changes = [
      name
    ]
  }
}

resource "azurerm_private_dns_a_record" "inference_fqdn" {
  count               = var.ai_hub.deploy_private_dns ? 1 : 0
  name                = "*.${azapi_resource.ai_hub.output.properties.workspaceId}.inference.${var.location}"
  zone_name           = azurerm_private_dns_zone.aml_private_dns[count.index].name
  resource_group_name = data.azurerm_resource_group.ai_resource_group.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.ml_private_endpoint.custom_dns_configs[2].ip_addresses[0]]
  lifecycle {
    ignore_changes = [
      name
    ]
  }
}



resource "azurerm_private_dns_a_record" "notebook_fqdn" {
  count               = var.ai_hub.deploy_private_dns ? 1 : 0
  name                = "ml-aihub-oai-${var.location}-${azapi_resource.ai_hub.output.properties.workspaceId}.notebooks"
  zone_name           = azurerm_private_dns_zone.notebook_private_dns[count.index].name
  resource_group_name = data.azurerm_resource_group.ai_resource_group.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.ml_private_endpoint.custom_dns_configs[1].ip_addresses[0]]
  lifecycle {
    ignore_changes = [
      name
    ]
  }
}
*/
resource "azurerm_private_dns_zone_virtual_network_link" "aml_dns_link" {
  count                  = var.ai_hub.deploy_private_dns ? 1 : 0
  name                   = "dns-link-${azurerm_private_dns_zone.aml_private_dns[count.index].name}"
  resource_group_name    = data.azurerm_resource_group.ai_resource_group.name
  private_dns_zone_name  = azurerm_private_dns_zone.aml_private_dns[count.index].name
  virtual_network_id     =var.vnet_id
  registration_enabled   = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "notebook_dns_link" {
  count                  = var.ai_hub.deploy_private_dns ? 1 : 0
  name                   = "dns-link-${azurerm_private_dns_zone.notebook_private_dns[count.index].name}"
  resource_group_name    = data.azurerm_resource_group.ai_resource_group.name
  private_dns_zone_name  = azurerm_private_dns_zone.notebook_private_dns[count.index].name
  virtual_network_id     =var.vnet_id
  registration_enabled   = false
}



// Conditional DNS and Link Creation
resource "azurerm_private_dns_zone" "key_vault_dns_zone" {
  count                = var.key_vault.deploy_storage_private_dns ? 1 : 0
  name                 = "privatelink.vaultcore.azure.net"
  resource_group_name  = data.azurerm_resource_group.ai_resource_group.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault_dns_zone_link" {
  count                 = var.key_vault.deploy_storage_private_dns ? 1 : 0
  name                  = "${azurerm_private_dns_zone.key_vault_dns_zone[count.index].name}-link"
  resource_group_name   = data.azurerm_resource_group.ai_resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault_dns_zone[count.index].name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}
/*
resource "azurerm_private_dns_a_record" "key_vault_dns_a_record" {
  count                = var.key_vault.deploy_storage_private_dns ? 1 : 0
  name                 = azurerm_key_vault.key_vault.name
  zone_name            = azurerm_private_dns_zone.key_vault_dns_zone[count.index].name
  resource_group_name  = data.azurerm_resource_group.ai_resource_group.name
  ttl                  = 300
  records              = [azurerm_private_endpoint.key_vault_private_endpoint[count.index].private_service_connection[0].private_ip_address]
  depends_on           = [azurerm_private_endpoint.key_vault_private_endpoint]
}

*/

// Private DNS Zone for Blob
resource "azurerm_private_dns_zone" "blob_dns_zone" {
  count               = var.storage.deploy_storage_private_dns ? 1 : 0
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = data.azurerm_resource_group.ai_resource_group.name
}

// Private DNS Zone for File
resource "azurerm_private_dns_zone" "file_dns_zone" {
  count               = var.storage.deploy_storage_private_dns ? 1 : 0
  name                = "privatelink.file.core.windows.net"
  resource_group_name = data.azurerm_resource_group.ai_resource_group.name
}

// Associate Blob DNS Zone with VNet
resource "azurerm_private_dns_zone_virtual_network_link" "blob_dns_zone_link" {
  count                = var.storage.deploy_storage_private_dns ? 1 : 0
  name                 = "blob-dns-zone-link"
  resource_group_name  = data.azurerm_resource_group.ai_resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.blob_dns_zone[0].name
  virtual_network_id   = var.vnet_id
}

// Associate File DNS Zone with VNet
resource "azurerm_private_dns_zone_virtual_network_link" "file_dns_zone_link" {
  count                = var.storage.deploy_storage_private_dns ? 1 : 0
  name                 = "file-dns-zone-link"
  resource_group_name  = data.azurerm_resource_group.ai_resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.file_dns_zone[0].name
  virtual_network_id   = var.vnet_id
}
/*
// DNS A Record for App Deployment Storage Blob
resource "azurerm_private_dns_a_record" "app_deploy_storage_blob_dns" {
  count               = var.storage.deploy_storage_private_dns ? 1 : 0
  name                = azurerm_storage_account.app_deploy_storage.name
  zone_name           = azurerm_private_dns_zone.blob_dns_zone[0].name
  resource_group_name = data.azurerm_resource_group.ai_resource_group.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.app_deploy_storage_private_endpoint.private_service_connection[0].private_ip_address]
}

// DNS A Record for Machine Learning Storage Blob
resource "azurerm_private_dns_a_record" "ml_storage_blob_dns" {
  count               = var.storage.deploy_storage_private_dns ? 1 : 0
  name                = azurerm_storage_account.ml_storage.name
  zone_name           = azurerm_private_dns_zone.blob_dns_zone[0].name
  resource_group_name = data.azurerm_resource_group.ai_resource_group.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.ml_blob_storage_private_endpoint.private_service_connection[0].private_ip_address]
}

// DNS A Record for Machine Learning Storage File
resource "azurerm_private_dns_a_record" "ml_storage_file_dns" {
  count               = var.storage.deploy_storage_private_dns ? 1 : 0
  name                = azurerm_storage_account.ml_storage.name
  zone_name           = azurerm_private_dns_zone.file_dns_zone[0].name
  resource_group_name = data.azurerm_resource_group.ai_resource_group.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.ml_file_storage_private_endpoint.private_service_connection[0].private_ip_address]
}
*/