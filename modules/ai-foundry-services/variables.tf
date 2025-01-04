
variable "base_name" {
  description = "This is the base name for each Azure resource name"
}

variable "location" {
  description = "The Azure region to deploy resources"
}

variable "resource_group_id" {
  description = "The resource group ID"
}

variable "resource_group_name" {

}

variable "private_endpoint_subnet_id" {
  description = "The subnet ID for the private endpoint"
}

variable "vnet_id" {
  description = "The VNet ID"
}
variable "search" {
  description = "Search service configuration"
  type = object({
    private_dns_zone_ids  = list(string)
    tags                  = map(string)
    sku_name              = string
    disable_local_auth    = bool
    hosting_mode          = string
    public_network_access = string
    partition_count       = number
    replica_count         = number
    semantic_search       = string
    search_identity_provider = object({
      type = string
    })
    encryption_with_cmk = optional(object({
      keySource = string
      keyVaultProperties = object({
        keyName     = string
        keyVersion  = string
        keyVaultUri = string
      })
    }))
    /*shared_private_links = list(object({
      groupId = string
      privateLinkResourceId = string
      requestMessage = string
    }))*/
    deploy_shared_private_link = bool
    deploy_private_dns_zones   = bool
  })
  default = {
    private_dns_zone_ids  = []
    tags                  = {}
    sku_name              = "standard"
    disable_local_auth    = true
    hosting_mode          = "default"
    public_network_access = "disabled"
    partition_count       = 1
    replica_count         = 1
    semantic_search       = "disabled"
    search_identity_provider = {
      type = "SystemAssigned"
    }
    encryption_with_cmk = null
    // shared_private_links = []
    deploy_shared_private_link = false
    deploy_private_dns_zones   = true
  }
}

variable "aiservice" {
  description = "AI Service configuration"
  type = object({
    private_dns_zone_ids     = list(string)
    aiServiceSkuName         = string
    disableLocalAuth         = bool
    deploy_private_dns_zones = bool
  })
  default = {
    private_dns_zone_ids     = []
    aiServiceSkuName         = "S0"
    disableLocalAuth         = false
    deploy_private_dns_zones = true
  }
}
