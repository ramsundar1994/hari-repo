variable "env" {
  default = "dev"
}

variable "vm_size" {
  type = map(string)
  default = {
    "dev"     = "Standard_D2s_v3"
    "prod"    = "Standard_D4s_v3"
    "nonprod" = "Standard_B1s"
    "test"    = "Standard_B1ms"
  }
}
variable "allowed_ports" {
  default = [22, 80, 443, 443]
}