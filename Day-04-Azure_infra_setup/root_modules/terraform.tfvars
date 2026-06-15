# ========== Terraform resource group values ===========

rgs = {
  rg1 = {
    name     = "rg-Lko"
    location = "australiacentral"
  }
  rg2 = {
    name     = "rg-delhi"
    location = "australiacentral"
  }
}

# ========== Terraform storage account values ===========
stg = {
  stg1 = {
    name                     = "stglko123"
    resource_group_name      = "rg-Lko"
    location                 = "australiacentral"
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }
  stg2 = {
    name                     = "stgdelhi123"
    resource_group_name      = "rg-delhi"
    location                 = "australiacentral"
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }
}

# ========== Terraform V-net values ===========
vnets = {
  vnet1 = {
    name                = "vnet-lko"
    location            = "australiacentral"
    resource_group_name = "rg-Lko"
    address_space       = ["10.0.0.0/24"]
  }
  vnet2 = {
    name                = "vnet-delhi"
    location            = "australiacentral"
    resource_group_name = "rg-delhi"
    address_space       = ["192.168.0.0/24"]
  }
}

# ========== Terraform Subnet value values ===========
subnets = {
  sub1 = {
    name                 = "AzureBastionSubnet"
    resource_group_name  = "rg-Lko"
    virtual_network_name = "vnet-lko"
    address_prefixes     = ["10.0.0.0/25"]
  }
  sub2 = {
    name                 = "backend-subnet"
    resource_group_name  = "rg-Lko"
    virtual_network_name = "vnet-lko"
    address_prefixes     = ["10.0.0.128/25"]
  }
  sub3 = {
    name                 = "frontend-subnet"
    resource_group_name  = "rg-delhi"
    virtual_network_name = "vnet-delhi"
    address_prefixes     = ["192.168.0.0/25"]
  }
  sub4 = {
    name                 = "backend-subnet"
    resource_group_name  = "rg-delhi"
    virtual_network_name = "vnet-delhi"
    address_prefixes     = ["192.168.0.128/25"]
  }
}

# ========== Terraform Virtual Machine values ===========
publicips = {
  ip1 = {
    name                = "lkopub_ip"
    location            = "australiacentral"
    resource_group_name = "rg-Lko"
    allocation_method   = "Static"
    sku                 = "Standard"
  }
}


bastion = {
  bastion1 = {
    name                = "jumpbastion"
    location            = "australiacentral"
    resource_group_name = "rg-Lko"
    subnet_id           = "/subscriptions/871888d5-61cf-427e-b227-7a4cd6ade4c5/resourceGroups/rg-Lko/providers/Microsoft.Network/virtualNetworks/vnet-lko/subnets/AzureBastionSubnet"
    public_ip_key       = "ip1"
  }
}