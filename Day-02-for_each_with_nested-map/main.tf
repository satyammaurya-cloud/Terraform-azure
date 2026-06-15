terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.74.0"
    }
  }
}
# ========================
provider "azurerm" {
  # Configuration options
  features {}
}
# =============================
# for_each with set

# resource "azurerm_resource_group" "rg" {

# for_each = toset([ "rg-1", "rg-2", "rg-3" ])

#   name     = each.value.name
#   location = each.value.location
# }

variable "x" {

}

resource "azurerm_resource_group" "rg" {

  for_each = toset(var.x)

  name     = each.key
  location = "centralindia"
}
