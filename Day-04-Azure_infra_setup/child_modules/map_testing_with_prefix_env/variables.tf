variable "rgs" {
  default = {
    rg1 = {
      name     = "hcl"
      location = "australiacentral"
    }
    rg2 = {
      name     = "tcs"
      location = "westus"
    }
  }
}

variable "vnets" {
  default = {
    vnet1 = {
      name          = "hcl"
      address_space = ["10.0.0.0/24"]
      location      = ""
      rg_key        = "rg1"
    }
    vnet2 = {
      name          = "tcs"
      address_space = ["10.0.1.0/24"]
      location      = ""
      rg_key        = "rg2"
    }
  }
}