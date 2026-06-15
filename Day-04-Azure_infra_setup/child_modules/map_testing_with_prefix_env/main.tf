resource "azurerm_resource_group" "rgs" {
  for_each = var.rgs

  # Accessing the nested properties using each.value
  name     = "${each.value.name}-resource-group"
  location = each.value.location
}


resource "azurerm_virtual_network" "vnets" {
  for_each = var.vnets

  name          = "${each.value.name}-virtual-network"
  address_space = each.value.address_space
  
  location      = azurerm_resource_group.rgs[each.value.rg_key].location

  resource_group_name = azurerm_resource_group.rgs[each.value.rg_key].name

}