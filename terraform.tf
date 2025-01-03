terraform {
  required_version = ">= 1.3.4"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.11.0"
    }

     azapi = {
      source = "azure/azapi"
    }
  }


}
