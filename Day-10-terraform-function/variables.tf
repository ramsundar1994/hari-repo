variable "rg" {
  type    = string
  default = "MYtesting-rg"
}
variable "stg-env" {
  type    = string
  default = "dev"
}
variable "rg1" {
  type    = string
  default = "MY testing rg"
}

variable "testing-rg" {
  type = object({
    name     = string
    location = string
  })

}