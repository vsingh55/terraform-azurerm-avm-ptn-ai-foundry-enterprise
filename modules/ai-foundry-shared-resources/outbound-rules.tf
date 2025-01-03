resource "azapi_update_resource" "ai_hub_update" {
  type       = "Microsoft.MachineLearningServices/workspaces@2024-07-01-preview"
  resource_id = var.ai_hub_id
  
  body = {
    properties = {
      managedNetwork = {
        outboundRules = var.ai_hub_outbound_rules
      }
    }
  }
}
