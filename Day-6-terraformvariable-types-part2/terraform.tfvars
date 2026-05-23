rg-details = {
  name = "testing-rg"
  location = "eastus"
}
nested-rg = {
  "dev" = {
    name = "dev-rg"
    location = "eastus"
    tags = {
      env = "dev"
      dept = "IT"
    }
  },
  "prod" = {
    name = "prod-rg"
    location = "westus"
    tags = {
      env = "prod"
      dept = "IT"
    }
  }
}
