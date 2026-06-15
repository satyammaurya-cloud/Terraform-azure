resource "azurerm_resource_group" "rg" {
  name     = "azure-rg"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnet-1" {
  name                = "vnet-A"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.1.0/24"]
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_virtual_network" "vnet-2" {
  name                = "vnet-B"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.2.0/24"]
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_virtual_network_peering" "peer-1" {
  name                      = "peer-A-to-B"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet-1.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-2.id
}

resource "azurerm_virtual_network_peering" "peer-2" {
  name                      = "peer-B-to-A"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet-2.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-1.id
}