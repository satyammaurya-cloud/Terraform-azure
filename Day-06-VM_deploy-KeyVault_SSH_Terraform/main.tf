# -----------------------------
# Existing Resource Group
# -----------------------------
data "azurerm_resource_group" "rg" {
  name = "DevSecOps-rg"
}

# -----------------------------
# Existing Key Vault
# -----------------------------
data "azurerm_key_vault" "kv" {
  name                = "Devsec-vault"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# -----------------------------
# Existing Key Vault Secrets
# -----------------------------
data "azurerm_key_vault_secret" "admin_user" {
  name         = "vm-admin-user"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "ssh_key" {
  name         = "vm-public-key"
  key_vault_id = data.azurerm_key_vault.kv.id
}

# -----------------------------
# VNET
# -----------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "devsecops-vnet"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  address_space = ["10.0.0.0/16"]
}

# -----------------------------
# Subnet
# -----------------------------
resource "azurerm_subnet" "subnet" {
  name                 = "vm-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = ["10.0.1.0/24"]
}

# -----------------------------
# NSG
# -----------------------------
resource "azurerm_network_security_group" "nsg" {
  name                = "vm-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# -----------------------------
# Public IP
# -----------------------------
resource "azurerm_public_ip" "pip" {
  name                = "vm-pip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  allocation_method = "Static"
  sku               = "Standard"
}

# -----------------------------
# NIC
# -----------------------------
resource "azurerm_network_interface" "nic" {
  name                = "vm-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# -----------------------------
# NSG Association
# -----------------------------
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# -----------------------------
# Linux VM
# -----------------------------
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "bastion-vm"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  size = "Standard_D2s_v3"

  admin_username = data.azurerm_key_vault_secret.admin_user.value

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_ssh_key {
    username   = data.azurerm_key_vault_secret.admin_user.value
    public_key = data.azurerm_key_vault_secret.ssh_key.value
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

