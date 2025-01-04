

locals {
  ai_service_name       = "ai-${var.base_name}"
  private_endpoint_name = "pep-${var.base_name}"
}

resource "azapi_resource" "ai_services" {
  type      = "Microsoft.CognitiveServices/accounts@2024-10-01"
  parent_id = var.resource_group_id
  name      = var.base_name
  location  = var.location
  identity {
    identity_ids = []
    type         = "SystemAssigned"
  }
  body = {
    kind = "AIServices"
    properties = {
      dynamicThrottlingEnabled = false
      networkAcls = {
        defaultAction = "Deny"
        ipRules       = []
        virtualNetworkRules = [
          {
            ignoreMissingVnetServiceEndpoint = true
            id                               = var.private_endpoint_subnet_id
          }
        ]
      }
      publicNetworkAccess           = "Disabled"
      restrictOutboundNetworkAccess = false
      allowedFqdnList               = []
      apiProperties                 = {}
      customSubDomainName           = var.base_name
      disableLocalAuth              = var.aiservice.disableLocalAuth
    }
    sku = {
      name = var.aiservice.aiServiceSkuName
    }
  }
  schema_validation_enabled = true
  ignore_casing             = false
  ignore_missing_property   = true
}

resource "azurerm_private_endpoint" "ai_services_private_endpoint" {
  name                = local.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "connection-${var.base_name}"
    private_connection_resource_id = azapi_resource.ai_services.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "ai-services-dns-group"

    private_dns_zone_ids = concat(
      var.aiservice.private_dns_zone_ids,
      var.aiservice.deploy_private_dns_zones ? [
        azurerm_private_dns_zone.cognitive_services[0].id,
        azurerm_private_dns_zone.openai[0].id,
        azurerm_private_dns_zone.services_ai[0].id
      ] : []
    )
  }
  tags = { "environment" = "production" }
}

output "aiServicesName" {
  description = "The name of the AI Services"
  value       = azapi_resource.ai_services.name
}

output "aiServicesId" {
  description = "The ID of the AI Services"
  value       = azapi_resource.ai_services.id
}

output "aiServicesPrincipalId" {
  description = "The Principal ID of the AI Services"
  value       = azapi_resource.ai_services.identity[0].principal_id
}

output "aiServices" {
  value       = azapi_resource.ai_services
}