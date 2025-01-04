
resource "azurerm_private_dns_zone" "cognitive_services" {
  count               = var.aiservice.deploy_private_dns_zones ? 1 : 0
  name                = "privatelink.cognitiveservices.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone" "openai" {
  count               = var.aiservice.deploy_private_dns_zones ? 1 : 0
  name                = "privatelink.openai.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone" "services_ai" {
  count               = var.aiservice.deploy_private_dns_zones ? 1 : 0
  name                = "privatelink.services.ai.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "cognitive_services_link" {
  count                 = var.aiservice.deploy_private_dns_zones ? 1 : 0
  name                  = "link-${var.base_name}-cognitiveservices"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.cognitive_services[count.index].name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "openai_link" {
  count                 = var.aiservice.deploy_private_dns_zones ? 1 : 0
  name                  = "link-${var.base_name}-openai"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.openai[count.index].name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "services_ai_link" {
  count                 = var.aiservice.deploy_private_dns_zones ? 1 : 0
  name                  = "link-${var.base_name}-services-ai"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.services_ai[count.index].name
  virtual_network_id    = var.vnet_id
}
/*
resource "azurerm_private_dns_a_record" "ai_services_dns" {
  count               = var.aiservice.deploy_private_dns_zones ? 1 : 0
  name                = var.base_name
  zone_name           = azurerm_private_dns_zone.cognitive_services[count.index].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.ai_services_private_endpoint.private_service_connection[0].private_ip_address]
}

resource "azurerm_private_dns_a_record" "openai_dns" {
  count               = var.aiservice.deploy_private_dns_zones ? 1 : 0
  name                = var.base_name
  zone_name           = azurerm_private_dns_zone.openai[count.index].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.ai_services_private_endpoint.private_service_connection[0].private_ip_address]
}

resource "azurerm_private_dns_a_record" "services_ai_dns" {
  count               = var.aiservice.deploy_private_dns_zones ? 1 : 0
  name                = var.base_name
  zone_name           = azurerm_private_dns_zone.services_ai[count.index].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.ai_services_private_endpoint.private_service_connection[0].private_ip_address]
}
*/

// DNS for Search
resource "azurerm_private_dns_zone" "search_dns_zone" {
  count = var.search.deploy_private_dns_zones ? 1 : 0
  name = "privatelink.search.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "search_dns_zone_link" {
  count = var.search.deploy_private_dns_zones ? 1 : 0
  name = "searchDnsZoneLink"
  resource_group_name = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.search_dns_zone[0].name
  virtual_network_id = var.vnet_id
  registration_enabled = false
}
/*
resource "azurerm_private_dns_a_record" "search_a_record" {
  count = var.search.deploy_private_dns ? 1 : 0
  name = azapi_resource.search_service.name
  zone_name = azurerm_private_dns_zone.search_dns_zone[0].name
  resource_group_name = var.resource_group_name
  ttl = 300
  records = [azurerm_private_endpoint.private_endpoint.private_service_connection[0].private_ip_address]
}*/

