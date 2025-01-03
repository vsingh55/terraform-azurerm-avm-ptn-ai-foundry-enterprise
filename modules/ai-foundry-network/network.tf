
locals {
    vnet_name              = "vnet-${var.base_name}"
    ddos_plan_name         = "ddos-${var.base_name}"
    enable_ddos_protection = !var.network.development_environment
}

resource "azurerm_network_ddos_protection_plan" "ddos_plan" {
    count                = var.deploy_network && local.enable_ddos_protection ? 1 : 0
    name                 = local.ddos_plan_name
    location             = var.network.location
    resource_group_name  = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
    count               = var.deploy_network ? 1 : 0
    name                = local.vnet_name
    location            = var.network.location
    resource_group_name = var.resource_group_name
    address_space       = [var.network.vnet_address_prefix]

    dynamic "ddos_protection_plan" {
        for_each = local.enable_ddos_protection ? [1] : []
        content {
            id     = azurerm_network_ddos_protection_plan.ddos_plan[0].id
            enable = true
        }
    }
}

# Subnets


resource "azurerm_subnet" "azure_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  address_prefixes     = [var.network.bastion_subnet_prefix]
}
resource "azurerm_subnet" "jumpbox" {
  name                 = "snet-jumpbox"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  address_prefixes     = [var.network.jumpbox_subnet_prefix]
}

resource "azurerm_subnet" "app_service_plan" {
    count                = var.deploy_network ? 1 : 0
    name                 = "snet-appServicePlan"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.vnet[0].name
    address_prefixes     = [var.network.app_services_subnet_prefix]

    delegation {
        name = "delegation"
        service_delegation {
            name = "Microsoft.Web/serverFarms"
        }
    }
}

resource "azurerm_subnet_network_security_group_association" "app_service_plan_nsg_assoc" {
    count                   = var.deploy_network ? 1 : 0
    subnet_id               = azurerm_subnet.app_service_plan[0].id
    network_security_group_id = azurerm_network_security_group.app_service_nsg[0].id
}

resource "azurerm_subnet" "app_gateway" {
    count                = var.deploy_network ? 1 : 0
    name                 = "snet-appGateway"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.vnet[0].name
    address_prefixes     = [var.network.app_gateway_subnet_prefix]
}

resource "azurerm_subnet_network_security_group_association" "jumpbox_nsg_assoc" {
    count                   = var.deploy_network ? 1 : 0
    subnet_id               = azurerm_subnet.jumpbox.id
    network_security_group_id = azurerm_network_security_group.jumpbox_nsg[0].id
}

resource "azurerm_subnet" "training" {
    count                = var.deploy_network ? 1 : 0
    name                 = "snet-training"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.vnet[0].name
    address_prefixes     = [var.network.training_subnet_prefix]
}

resource "azurerm_subnet_network_security_group_association" "training_nsg_assoc" {
    count                   = var.deploy_network ? 1 : 0
    subnet_id               = azurerm_subnet.training[0].id
    network_security_group_id = azurerm_network_security_group.training_nsg[0].id
}

resource "azurerm_subnet" "scoring" {
    count                = var.deploy_network ? 1 : 0
    name                 = "snet-scoring"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.vnet[0].name
    address_prefixes     = [var.network.scoring_subnet_prefix]
}

resource "azurerm_subnet_network_security_group_association" "scoring_nsg_assoc" {
    count                   = var.deploy_network ? 1 : 0
    subnet_id               = azurerm_subnet.scoring[0].id
    network_security_group_id = azurerm_network_security_group.scoring_nsg[0].id
}

# NSGs
resource "azurerm_network_security_group" "app_gateway_nsg" {
    count                = var.deploy_network ? 1 : 0
    name                 = "nsg-appGatewaySubnet"
    location             = var.network.location
    resource_group_name  = var.resource_group_name

    security_rule {
        name                       = "AppGw.In.Allow.ControlPlane"
        description                = "Allow inbound Control Plane"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "65200-65535"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        access                     = "Allow"
        priority                   = 100
        direction                  = "Inbound"
    }

    security_rule {
        name                       = "AppGw.In.Allow443.Internet"
        description                = "Allow ALL inbound web traffic on port 443"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "Internet"
        destination_address_prefix = var.network.app_gateway_subnet_prefix
        access                     = "Allow"
        priority                   = 110
        direction                  = "Inbound"
    }

    security_rule {
        name                       = "AppGw.In.Allow.LoadBalancer"
        description                = "Allow inbound traffic from azure load balancer"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
        access                     = "Allow"
        priority                   = 120
        direction                  = "Inbound"
    }

    security_rule {
        name                       = "DenyAllInBound"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        access                     = "Deny"
        priority                   = 1000
        direction                  = "Inbound"
    }

    security_rule {
        name                       = "AppGw.Out.Allow.PrivateEndpoints"
        description                = "Allow outbound traffic from the App Gateway subnet to the Private Endpoints subnet."
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = var.network.app_gateway_subnet_prefix
        destination_address_prefix = var.network.private_endpoints_subnet_prefix
        access                     = "Allow"
        priority                   = 100
        direction                  = "Outbound"
    }

    security_rule {
        name                       = "AppPlan.Out.Allow.AzureMonitor"
        description                = "Allow outbound traffic from the App Gateway subnet to Azure Monitor"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = var.network.app_gateway_subnet_prefix
        destination_address_prefix = "AzureMonitor"
        access                     = "Allow"
        priority                   = 110
        direction                  = "Outbound"
    }
}

# Repeat similar NSG definitions for each subnet NSG
resource "azurerm_network_security_group" "app_service_nsg" {
    count                = var.deploy_network ? 1 : 0
    name                 = "nsg-appServicesSubnet"
    location             = var.network.location
    resource_group_name  = var.resource_group_name

    security_rule {
        name                       = "AppPlan.Out.Allow.PrivateEndpoints"
        description                = "Allow outbound traffic from the app service subnet to the private endpoints subnet"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = var.network.app_services_subnet_prefix
        destination_address_prefix = var.network.private_endpoints_subnet_prefix
        access                     = "Allow"
        priority                   = 100
        direction                  = "Outbound"
    }

    security_rule {
        name                       = "AppPlan.Out.Allow.AzureMonitor"
        description                = "Allow outbound traffic from app service to AzureMonitor ServiceTag."
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = var.network.app_services_subnet_prefix
        destination_address_prefix = "AzureMonitor"
        access                     = "Allow"
        priority                   = 110
        direction                  = "Outbound"
    }
}

resource "azurerm_network_security_group" "private_endpoints_nsg" {
    count                = var.deploy_network ? 1 : 0
    name                 = "nsg-privateEndpointsSubnet"
    location             = var.network.location
    resource_group_name  = var.resource_group_name

    security_rule {
        name                       = "DenyAllOutBound"
        description                = "Deny outbound traffic from the private endpoints subnet"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = var.network.private_endpoints_subnet_prefix
        destination_address_prefix = "*"
        access                     = "Deny"
        priority                   = 1000
        direction                  = "Outbound"
    }
}



resource "azurerm_network_security_group" "bastion_nsg" {
    count                = var.deploy_network ? 1 : 0
    name                 = "nsg-bastionSubnet"
    location             = var.network.location
    resource_group_name  = var.resource_group_name

    security_rule {
        name                       = "GatewayManager"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "GatewayManager"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "Internet-Bastion-PublicIP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "OutboundVirtualNetwork"
        priority                   = 1001
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["22","3389"]
        source_address_prefix      = "*"
        destination_address_prefix = "VirtualNetwork"
    }

    security_rule {
        name                       = "OutboundToAzureCloud"
        priority                   = 1002
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "AzureCloud"
    }
}

resource "azurerm_network_security_group" "jumpbox_nsg" {
    count                = var.deploy_network ? 1 : 0
    name                 = "nsg-jumpboxSubnet"
    location             = var.network.location
    resource_group_name  = var.resource_group_name

    security_rule {
        name                       = "Jumpbox.In.Allow.SshRdp"
        description                = "Allow inbound RDP and SSH from the Bastion Host subnet"
        protocol                   = "Tcp"
        source_port_range          = "*"
        source_address_prefix      = var.network.bastion_subnet_prefix
        destination_port_ranges    = ["22", "3389"]
        destination_address_prefix = var.network.jumpbox_subnet_prefix
        access                     = "Allow"
        priority                   = 100
        direction                  = "Inbound"
    }

    security_rule {
        name                       = "Jumpbox.Out.Allow.PrivateEndpoints"
        description                = "Allow outbound traffic from the jumpbox subnet to the Private Endpoints subnet."
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = var.network.jumpbox_subnet_prefix
        destination_address_prefix = var.network.private_endpoints_subnet_prefix
        access                     = "Allow"
        priority                   = 100
        direction                  = "Outbound"
    }

    security_rule {
        name                       = "Jumpbox.Out.Allow.Internet"
        description                = "Allow outbound traffic from all VMs to Internet"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = var.network.jumpbox_subnet_prefix
        destination_address_prefix = "Internet"
        access                     = "Allow"
        priority                   = 130
        direction                  = "Outbound"
    }

    security_rule {
        name                       = "DenyAllOutBound"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = var.network.jumpbox_subnet_prefix
        destination_address_prefix = "*"
        access                     = "Deny"
        priority                   = 1000
        direction                  = "Outbound"
    }
}

resource "azurerm_network_security_group" "training_nsg" {
    count                = var.deploy_network ? 1 : 0
    name                 = "nsg-trainingSubnet"
    location             = var.network.location
    resource_group_name  = var.resource_group_name

    security_rule {
        name                       = "DenyAllOutBound"
        description                = "Deny outbound traffic from the training subnet"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = var.network.training_subnet_prefix
        destination_address_prefix = "*"
        access                     = "Deny"
        priority                   = 1000
        direction                  = "Outbound"
    }
}

resource "azurerm_network_security_group" "scoring_nsg" {
    count                = var.deploy_network ? 1 : 0
    name                 = "nsg-scoringSubnet"
    location             = var.network.location
    resource_group_name  = var.resource_group_name

    security_rule {
        name                       = "DenyAllOutBound"
        description                = "Deny outbound traffic from the scoring subnet"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = var.network.scoring_subnet_prefix
        destination_address_prefix = "*"
        access                     = "Deny"
        priority                   = 1000
        direction                  = "Outbound"
    }
}

# Outputs
output "vnet_name" {
    description = "The name of the virtual network"
    value       = azurerm_virtual_network.vnet[0].name
}

output "vnet_id" {
    description = "The ID of the virtual network"
    value       = azurerm_virtual_network.vnet[0].id   
  
}

output "app_services_subnet_name" {
    description = "The name of the app services subnet"
    value       = azurerm_subnet.app_service_plan[0].name
}

output "app_gateway_subnet_name" {
    description = "The name of the app gateway subnet"
    value       = azurerm_subnet.app_gateway[0].name
}

output "private_endpoints_subnet_name" {
    description = "The name of the private endpoints subnet"
    value       = azurerm_subnet.private_endpoints.name
}

output "private_endpoints_subnet_id" {
    description = "The ID of the private endpoints subnet"
    value       = azurerm_subnet.private_endpoints.id
}

output "bastion_subnet_name" {
    description = "The name of the Azure Bastion subnet"
    value       = azurerm_subnet.azure_bastion.name
}

output "jumpbox_subnet_name" {
    description = "The name of the jumpbox subnet"
    value       = azurerm_subnet.jumpbox.name
}

output "training_subnet_name" {
    description = "The name of the training subnet"
    value       = azurerm_subnet.training[0].name
}

output "scoring_subnet_name" {
    description = "The name of the scoring subnet"
    value       = azurerm_subnet.scoring[0].name
}

# Subnet for Private Endpoints
resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-privateEndpoints"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  address_prefixes     = [var.network.private_endpoints_subnet_prefix]

  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_subnet_network_security_group_association" "private_endpoints_nsg_assoc" {
  count                    = var.deploy_network ? 1 : 0
  subnet_id                = azurerm_subnet.private_endpoints.id
  network_security_group_id = azurerm_network_security_group.private_endpoints_nsg[0].id
}

# Subnet for Agents
resource "azurerm_subnet" "agents" {
  name                 = "snet-agents"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  address_prefixes     = [var.network.agents_subnet_prefix]
}


# NSG for Agents
resource "azurerm_network_security_group" "agents_nsg" {
  count               = var.deploy_network ? 1 : 0
  name                = "nsg-agentsSubnet"
  location            = var.network.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "DenyAllOutBound"
    description                = "Deny outbound traffic from the build agents subnet"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.network.agents_subnet_prefix
    destination_address_prefix = "*"
    access                     = "Deny"
    priority                   = 1000
    direction                  = "Outbound"
  }
}

# NSG Association for Azure Bastion
resource "azurerm_subnet_network_security_group_association" "azure_bastion_nsg_assoc" {
  count                    = var.deploy_network ? 1 : 0
  subnet_id                = azurerm_subnet.azure_bastion.id
  network_security_group_id = azurerm_network_security_group.bastion_nsg[0].id
}
