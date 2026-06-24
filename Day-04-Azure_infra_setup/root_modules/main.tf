module "resource_group" {
  source = "../child_modules/azurerm_resource_group"

  rgs = var.rgs
}




module "storage_account" {
  depends_on = [module.resource_group]
  source     = "../child_modules/azurerm_storage_account"

  stg = var.stg
}

module "virtual_network" {
  depends_on = [module.resource_group]
  source     = "../child_modules/azurerm_virtual_network"
  vnet       = var.vnets
}

module "subnet" {
  depends_on = [module.virtual_network]
  source     = "../child_modules/azurerm_subnet"
  subnet     = var.subnets
}

module "bastion" {
  depends_on = [module.subnet]
  source     = "../child_modules/azurerm_bastion"

  publicips = var.publicips
  bastion   = var.bastion
}