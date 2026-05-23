variable "rg-details" {
  type = object({
    name = string
    location = string
  })
  default = {
    name = ""
    location = ""
  }
}
variable "nested-rg" {
  type = map(object({
    name = string
    location = string
    tags = map(string)
  }))
}