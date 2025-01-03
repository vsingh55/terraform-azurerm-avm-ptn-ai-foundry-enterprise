

// Azure Search Service
resource "azapi_resource" "search_service" {
  type      = "Microsoft.Search/searchServices@2024-03-01-preview"
  name      = "as-${var.base_name}"
  location  = var.location
  tags      = var.search.tags
  parent_id = var.resource_group_id
  body = {
    identity = var.search.search_identity_provider
    properties = {
      authOptions = var.search.disable_local_auth ? null : {
        aadOrApiKey = {
          aadAuthFailureMode = "http401WithBearerChallenge"
        }
      }
      disableLocalAuth    = var.search.disable_local_auth
      encryptionWithCmk   = var.search.encryption_with_cmk
      hostingMode         = var.search.hosting_mode
      partitionCount      = var.search.partition_count
      publicNetworkAccess = var.search.public_network_access
      replicaCount        = var.search.replica_count
      semanticSearch      = var.search.semantic_search
      networkRuleSet = {
        ipRules = []
        bypass  = "AzureServices"
      }
    }
    sku = {
      name = var.search.sku_name
    }
  }
}


// Private Endpoint for Search
resource "azurerm_private_endpoint" "private_endpoint" {
  name                = "${var.base_name}-privateEndpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "searchServiceConnection"
    private_connection_resource_id = azapi_resource.search_service.id
    subresource_names              = ["searchService"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name = "ai-services-dns-group"

    private_dns_zone_ids = length(var.search.private_dns_zone_ids) > 0 ? var.search.private_dns_zone_ids : (
      var.search.deploy_private_dns_zones ? [azurerm_private_dns_zone.search_dns_zone[0].id] : []
    )
  }
}

output "search_service_id" {
  value = azapi_resource.search_service.id
}
