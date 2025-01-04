

locals {
  bastion_host_name  = "ab-${var.base_name}"
  jump_box_name = length("jmp-${var.base_name}") > 15 ? substr("jmp-${var.base_name}", 0, 15) : "jmp-${var.base_name}"
}

resource "random_password" "jump_box_admin_password" {
  length  = 16
  special = true
}

resource "azurerm_public_ip" "bastion_public_ip" {
  count                = var.deploy_network && var.deploy_bastion ? 1 : 0  # Adjust deployment logic
  name                 = "pip-${local.bastion_host_name}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  allocation_method    = "Static"
  sku                  = "Standard"
  zones                = ["1", "2", "3"]
}

resource "azurerm_bastion_host" "bastion" {
  count                = var.deploy_network && var.deploy_bastion ? 1 : 0  # Adjust deployment logic
  name                 = local.bastion_host_name
  location             = var.location
  resource_group_name  = var.resource_group_name
  sku                  = "Basic"

  ip_configuration {
    name                 = "default"
    subnet_id            = azurerm_subnet.azure_bastion.id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip[0].id
  }
}

resource "azurerm_network_interface" "jump_box_nic" {
  name                = "nic-${local.jump_box_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.jumpbox.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = null
  }
}

resource "azurerm_windows_virtual_machine" "jump_box" {
  name                  = "vm-${local.jump_box_name}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.jump_box_nic.id]
  size                  = var.config.vm_size
  admin_username        = var.config.jump_box_admin_name
  admin_password        = var.config.jump_box_admin_password != "" ? var.config.jump_box_admin_password : random_password.jump_box_admin_password.result
  computer_name         = local.jump_box_name

  provision_vm_agent = true

  source_image_reference {
    publisher = var.config.image_publisher
    offer     = var.config.image_offer
    sku       = var.config.image_sku
    version   = var.config.image_version
  }

  os_disk {
    name                = "osdisk-${local.jump_box_name}"
    caching             = var.config.os_disk_caching
    storage_account_type = var.config.os_disk_storage_account_type
  }
}

resource "azurerm_virtual_machine_extension" "vm_access" {
  name                 = "enablevmAccess"
  virtual_machine_id   = azurerm_windows_virtual_machine.jump_box.id
  publisher            = "Microsoft.Compute"
  type                 = "VMAccessAgent"
  type_handler_version = "2.0"
  lifecycle {
    ignore_changes = [
      settings
    ]
  }
}

resource "azurerm_virtual_machine_extension" "azure_monitor_agent" {
  name                 = "AzureMonitorWindowsAgent"
  virtual_machine_id   = azurerm_windows_virtual_machine.jump_box.id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorWindowsAgent"
  type_handler_version = "1.21"
}

resource "azurerm_virtual_machine_extension" "dependency_agent" {
  name                 = "DependencyAgentWindows"
  virtual_machine_id   = azurerm_windows_virtual_machine.jump_box.id
  publisher            = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                 = "DependencyAgentWindows"
  type_handler_version = "9.10"
}
