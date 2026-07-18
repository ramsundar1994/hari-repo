variable "subnet" {
  default = [
    {
      name           = "subnet-a"
      address_prefix = ["10.0.1.0/24"] ## 256 IPAddress"
    },
    {
      name           = "subnet-b"
      address_prefix = ["10.0.0.0/24"] ## 256 IPAddress"
    }
  ]
}
variable "nsg" {
  default = [
    {
      name                       = "Allow-RDP"
      priority                   = "100"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp",
      source_port_range          = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      destination_port_range     = "3389"

    },
    {
      name                       = "Allow-HTTP"
      priority                   = "200"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp",
      source_port_range          = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      destination_port_range     = "80"

    },
    {
      name                       = "Allow-HTTPS"
      priority                   = "300"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp",
      source_port_range          = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      destination_port_range     = "443"
    }
  ]
}