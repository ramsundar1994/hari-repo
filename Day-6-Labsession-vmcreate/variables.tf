variable "rg-details" {
  type = object({
    name     = string
    location = string
  })
}
variable "vnet-details" {
  type = object({
    name          = string
    address_space = list(string)
  })
}
variable "subnet-details" {
  type = object({
    name             = string
    address_prefixes = list(string)
  })
}
variable "nics" {
  type = list(string)
}
variable "vm_details" {
  type = object({
    name           = string
    size           = string
    admin_username = string
    admin_password = string
    publisher      = string
    offer          = string
    sku            = string
    version        = string

  })
}
variable "tags" {
  type = map(string)
  default = {

  }
}