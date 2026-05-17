variable "rg-name" {
  type        = string
  description = "resourcegroup name"
  default     = "har-rg"
}
variable "loc" {
  type        = string
  description = "location of resource group"
  default     = "eastus"
}
variable "rg-names" {
  type        = list(string)
  description = "list of resource group names"
  default     = []
}
variable "locations" {
  type        = list(string)
  description = "list of locations for resource groups"
  default     = []
}
variable "env" {
  type        = string
  description = "environment for resource group"
  default     = "Nonprod"
}
variable "rg-details" {
  type = map(string)
  default = {
    "keyrg1" = "westus"
  } 
}