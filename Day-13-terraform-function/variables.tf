variable "subnets" {
  default = {
    "subnet-A" = "10.0.0.0/24"
    "subnet-B" = "10.0.1.0/24"
    "subnet-C" = "10.0.2.0/24"
    "subnet-D" = "10.0.3.0/24"
  }
}
variable "sub" {
    default = ["10.0.4.0/24", "10.0.5.0/24"]
}