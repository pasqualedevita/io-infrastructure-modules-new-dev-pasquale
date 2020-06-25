provider "azurerm" {
  version = "=2.11.0"
  features {}
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "azurerm" {}
}

module "app_service_plan" {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_app_service_plan?ref=v2.0.28"

  global_prefix     = var.global_prefix
  environment       = var.environment
  environment_short = var.environment_short
  region            = var.region

  name                = "app${var.name}"
  resource_group_name = var.resource_group_name
  kind                = var.app_service_plan_info.kind
  sku_tier            = var.app_service_plan_info.sku_tier
  sku_size            = var.app_service_plan_info.sku_size
}

resource "azurerm_app_service" "app_service" {
  name                = local.resource_name
  resource_group_name = var.resource_group_name
  location            = var.region
  app_service_plan_id = module.app_service_plan.id
  enabled             = var.app_enabled
  https_only          = var.https_only
  client_cert_enabled = var.client_cert_enabled

  site_config {
    always_on       = var.always_on
    min_tls_version = "1.2"
    ftps_state      = "Disabled"
  }

  app_settings = merge(
    {
      APPINSIGHTS_INSTRUMENTATIONKEY = var.application_insights_instrumentation_key
    },
    var.app_settings
  )

  tags = {
    environment = var.environment
  }

}
