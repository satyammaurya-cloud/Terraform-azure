terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.76.0"
    }
  }
  backend "local" {
    path = "terraform.tfstate"

  }
}

provider "azurerm" {
  features {}
}