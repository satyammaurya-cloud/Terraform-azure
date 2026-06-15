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
# for_each with nested map

variable "rgs" {
 default = {
    rg1 = {
      name       = "rg-chatri"
      location   = "westus"
      managed_by = "ramanujan"
    }
    rg2 = {
      name       = "rg-khatri"
      location   = "eastus"
      managed_by = "terraform"
    }
  }
}

resource "azurerm_resource_group" "rg" {

  for_each = var.rgs

  name       = each.value.name
  location   = each.value.location
  managed_by = each.value.managed_by
}