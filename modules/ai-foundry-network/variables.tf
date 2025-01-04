variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}



variable "deploy_network" {
    description = "Flag to deploy network resources"
    type        = bool
    default     = true
}


variable "deploy_bastion" {
  description = "Flag to deploy the Bastion host"
  type        = bool
  default     = true
}
variable "base_name" {
  description = "Base name for resources"
  type        = string
}
variable "network" {
    description = "Network configuration"
    type = object({
       
        location                    = string
        development_environment     = bool
        vnet_address_prefix         = string
        app_services_subnet_prefix  = string
        app_gateway_subnet_prefix   = string
        private_endpoints_subnet_prefix = string
        agents_subnet_prefix        = string
        bastion_subnet_prefix       = string
        jumpbox_subnet_prefix       = string
        training_subnet_prefix      = string
        scoring_subnet_prefix       = string
    })
}

variable "config" {
  description = "Configuration for the jump box"
  type = object({
    log_workspace_name          = string
    jump_box_admin_name         = string
    jump_box_admin_password     = string
    vm_size                     = string
    image_publisher             = string
    image_offer                 = string
    image_sku                   = string
    image_version               = string
    os_disk_caching             = string
    os_disk_storage_account_type = string
  })
  default = {
    log_workspace_name          = ""
    jump_box_admin_name         = "vmadmin"
    jump_box_admin_password     = ""
    vm_size                     = "Standard_DS1_v2"
    image_publisher             = "MicrosoftWindowsServer"
    image_offer                 = "WindowsServer"
    image_sku                   = "2019-Datacenter"
    image_version               = "latest"
    os_disk_caching             = "ReadWrite"
    os_disk_storage_account_type = "Standard_LRS"
  }
}


variable "location" {
  description = "Location for resources"
  type        = string
}
