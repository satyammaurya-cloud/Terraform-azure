
# <---------- Resourcs Group ------------>

resource "azurerm_resource_group" "tcs_rg" {

  name     = "${var.prefix}-resources-group"
  location = "West Europe"
}

# <---------- Virtual Network ------------>

resource "azurerm_virtual_network" "v_net" {
  name                = "${var.prefix}-virtual-network"
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.tcs_rg.location
  resource_group_name = azurerm_resource_group.tcs_rg.name
}

# <---------- Frontend Subnet ------------>

resource "azurerm_subnet" "frontend_subnet" {
  name                 = "frontend-subnet"
  resource_group_name  = azurerm_resource_group.tcs_rg.name
  virtual_network_name = azurerm_virtual_network.v_net.name
  address_prefixes     = ["10.0.0.0/25"]
}

# <---------- Cust public ip for vm ------------>

resource "azurerm_public_ip" "cust_pub_ip" {
  name                = "${var.prefix}-public-ip"
  resource_group_name = azurerm_resource_group.tcs_rg.name
  location            = azurerm_resource_group.tcs_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# <---------- Cust Network card interface ------------>

resource "azurerm_network_interface" "cust_nic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.tcs_rg.location
  resource_group_name = azurerm_resource_group.tcs_rg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.frontend_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.cust_pub_ip.id
  }
}

# <---------- Vitrual Machine ------------>

resource "azurerm_virtual_machine" "tcs_vm" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.tcs_rg.location
  resource_group_name   = azurerm_resource_group.tcs_rg.name
  network_interface_ids = [azurerm_network_interface.cust_nic.id]
  vm_size               = "Standard_D2s_v3"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "web-server"
  }
}

# <---------- Network Security Group ------------>

resource "azurerm_network_security_group" "cust_nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.tcs_rg.location
  resource_group_name = azurerm_resource_group.tcs_rg.name

  security_rule {
    name                       = "ssh-rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "htt-rule"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "web-server-nsg"
  }
}

# <---------- Cust NSG attachment to NIC card that is already attach to our VM ------------>

# This will attach the network security group to your VM's network card

resource "azurerm_network_interface_security_group_association" "nsg_attachment" {
  network_interface_id      = azurerm_network_interface.cust_nic.id
  network_security_group_id = azurerm_network_security_group.cust_nsg.id
}