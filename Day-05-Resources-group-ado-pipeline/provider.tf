terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "4.77.0"
    }
  }
  # backend "azurerm" {
  #   storage_account_name = "adostorageaccount123"
  #   container_name = "ado-container-statefile"
  #   key = "terraform.tfstate"
    
  # }
}

provider "azurerm" {
    features {}
  
}