#Example1
locals {
  vm_number = 1
  vmname = "vm-${local.vm_number}"
  #vmname = "vm-${tostring(local.vm_number)}"
}
output "vmname" {
  value = local.vmname
}
#Example 2: Looping -Count 
variable "vm" {
  default = 3
}
output "vm-names" {
  value = [ for number in range(var.vm) : "VM-${number}" ]
}

#Exmple 3: 
variable "location" {
  default = ["eastus", "westus" ,"centralus"]
}
locals {
  resource_group = {
    for loc in var.location : "rg-${loc}" => loc
  }
}
resource "azurerm_resource_group" "rg-test" {
  for_each = local.resource_group
  name =  each.key
  location =  each.value
}

#Example 4 : For each loop using ( for function)
variable "ports" {
  default = {
    ssh = 22
    https = 443
  }
}
output "vm-ports" {
  value = {
    for name,port in var.ports : name => "port-${port}"
  }
}
#Example 5 : For Expression (Filtering & Transformation )
variable "Database-vm" {
  default = ["sqlvm","cosmosdbvm"]
}
output "db-output" {
  value = [ for db in var.Database-vm : upper(db) ]
}