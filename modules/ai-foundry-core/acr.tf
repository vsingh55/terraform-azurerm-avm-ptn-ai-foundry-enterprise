

// Container Registry
resource "azurerm_container_registry" "acr" {
  name                     = "cr${var.base_name}"
  location                 = var.location
  resource_group_name      = data.azurerm_resource_group.ai_resource_group.name
  sku                      = "Premium"
  admin_enabled            = false

  network_rule_set {
    default_action         = "Deny"
  }
}

// Conditional Private Endpoint Creation
resource "azurerm_private_endpoint" "acr_private_endpoint" {
  count               = var.acr.deploy_acr_private_dns ? 1 : 0
  name                = "pep-${azurerm_container_registry.acr.name}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.ai_resource_group.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "acrConnection"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  
  private_dns_zone_group {
    name = "acr-dns-group"

    private_dns_zone_ids = concat(
      var.acr.private_dns_zone_ids, // Define this variable for existing custom Key Vault DNS zones if needed.
      
      // Conditional DNS Zone IDs
      var.acr.deploy_acr_private_dns ? [
        azurerm_private_dns_zone.acr_dns_zone[0].id,  // If needed
      ] : []
    )
  }
}


// Output to get the ACR login server
output "login_server" {
  description = "The login server of the Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}
