provider "azurerm" {
  version = "=2.11.0"
  features {}
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "azurerm" {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.fullname != null ? var.fullname : local.resource_name
  location = var.region

  tags = {
    environment = var.environment
  }
}
