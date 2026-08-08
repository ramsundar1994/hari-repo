variable "vm_config" {
  type = map(object({
    vm_size        = string
    admin_username = string
    admin_password = string
    nic_count      = number
    image_sku      = string
  }))
}