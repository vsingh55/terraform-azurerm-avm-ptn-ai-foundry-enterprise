
variable "base_name" {
  description = "This is the base name for each Azure resource name"
}

variable "location" {
  description = "The Azure region to deploy resources"
}

variable "resource_group_id" {
  description = "The resource group ID"
}

variable "private_endpoint_subnet_id" {
  description = "The subnet ID for the private endpoint"
}

variable "vnet_id" {
  description = "The VNet ID"
}

variable "storage" {
  description = "Storage configuration"
  type = object({
private_dns_zone_ids = list(string)
    deploy_storage_private_dns = bool,
   
  })
  default = {
    private_dns_zone_ids = []
    deploy_storage_private_dns = true,

  }
}

variable "key_vault" {
  description = "Configuration for Key Vault"
  type = object({
   private_dns_zone_ids  = list(string)
    deploy_storage_private_dns = bool

  })
  default = {
   private_dns_zone_ids   = []
    deploy_storage_private_dns = true

  }
}


variable "ai_hub" {
  description = "AI Hub configuration"
  type = object({
    tags = map(string)
    deploy_private_dns = bool
    description = string
      private_dns_zone_ids = list(string)
  })

  default = {
    private_dns_zone_ids = []
    tags = {
      environment = "production"
    }
    deploy_private_dns = true
    description = "AI hub for machine learning workspace"
  }
}

variable "acr" {
  description = "Configuration for ACR"
  type = object({
   private_dns_zone_ids  = list(string)
    deploy_acr_private_dns = bool
  })
  default = {
private_dns_zone_ids = []
    deploy_acr_private_dns = true
  }
}