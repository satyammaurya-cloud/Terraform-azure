resource "azurerm_public_ip" "publicip" {
  for_each = var.publicips

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku

}

resource "azurerm_bastion_host" "bastion" {
  for_each = var.bastion

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name      = "configuration"
    subnet_id = each.value.subnet_id
    public_ip_address_id = azurerm_public_ip.publicip[each.value.public_ip_key].id

  }
}

  