terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.74.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

variable "rgs" {

  default ={
    somu = "centralus"
    monu = "eastus"
     }
}

resource "azurerm_resource_group" "rg_block" {

 for_each = var.rgs

   name = each.key
   location = each.value
}

# output "rg-names" {
#   value = values(azurerm_resource_group.rg_block)[*].name

# }
# output "rg-location" {
#    value = values(azurerm_resource_group.rg_block)[*].location
# }

output "rg_details" {

  value = [
    for rg in azurerm_resource_group.rg_block : {
      name     = rg.name
      location = rg.location
    }
  ]

}