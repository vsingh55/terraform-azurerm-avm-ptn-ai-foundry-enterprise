// Shared Private Link Resources
resource "azurerm_search_shared_private_link_service" "shared_private_link" {
  count = var.shared_private_link.deploy_shared_private_link ? length(var.shared_private_link.shared_private_links) : 0

  name                = "search-shared-private-link-${count.index}"
  search_service_id   = var.shared_private_link.target_service_id
  subresource_name    = var.shared_private_link.shared_private_links[count.index].groupId
  target_resource_id  = var.shared_private_link.shared_private_links[count.index].privateLinkResourceId
  request_message     = var.shared_private_link.shared_private_links[count.index].requestMessage
}
/*

resource "null_resource" "approve_private_link" {
  count = var.shared_private_link.deploy_shared_private_link ? length(var.shared_private_link.shared_private_links) : 0

  provisioner "local-exec" {
    command = var.os_type == "windows" ? join("\n", [
      "$resourceGroup = (${azurerm_search_shared_private_link_service.shared_private_link[count.index].target_resource_id} -split '/')[4]",
      "az network private-endpoint-connection approve --resource-group $resourceGroup --name ${azurerm_search_shared_private_link_service.shared_private_link[count.index].name} --resource-name ${azurerm_search_shared_private_link_service.shared_private_link[count.index].target_resource_id} --type Microsoft.Search/searchServices/privateLinkResources --description 'Auto-approved by Terraform'"
    ]) : join("\n", [
      "RESOURCE_GROUP=$(echo ${azurerm_search_shared_private_link_service.shared_private_link[count.index].target_resource_id} | grep -o -P '(?<=resourceGroups/)[^/]+' | head -1)",
      "az network private-endpoint-connection approve --resource-group $RESOURCE_GROUP --name ${azurerm_search_shared_private_link_service.shared_private_link[count.index].name} --resource-name ${azurerm_search_shared_private_link_service.shared_private_link[count.index].target_resource_id} --type Microsoft.Search/searchServices/privateLinkResources --description 'Auto-approved by Terraform'"
    ])
    interpreter = var.os_type == "windows" ? ["PowerShell", "-Command"] : ["/bin/sh", "-c"]
  }

  depends_on = [azurerm_search_shared_private_link_service.shared_private_link]
}*/

