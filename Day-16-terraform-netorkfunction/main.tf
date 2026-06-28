variable "vnet" {
  default = "10.0.0.0/18" ##65536  /17,/18/19/20/21/22/23/24/25/26/27/28/29
}
## subnet function, hosthunction --IP
locals {
  # syntax = cidrsubnet(base, newbits, subnet number)
  web_subnet      = cidrsubnet(var.vnet, 7, 0) ## /18 +7 =25   10.0.0.0/25 =128  0 to 127 = subnet number 0
  app_subnet      = cidrsubnet(var.vnet, 7, 1) ##                                    ##128 to 255 = subnet number 1
  function_subnet = cidrsubnet(var.vnet, 7, 2)
  fun_subnet      = cidrsubnet(var.vnet, 7, 3) ## 10.0.1.0 to 10.0.1.127 
  # syntax = cidrhost(subnetname prefix, hostnumber)
  web_ip = cidrhost(local.web_subnet, 125)
}
output "subnets" {
  value = {
    websubnet       = local.web_subnet
    appsubnet       = local.app_subnet
    function_subnet = local.function_subnet
    fun_subnet      = local.fun_subnet
    web_ip          = local.web_ip
  }
}