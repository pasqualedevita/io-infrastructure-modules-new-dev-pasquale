provider "azurerm" {
  version = "=2.4.0"
  features {}
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "azurerm" {}
}

module "storage_account" {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_storage_account?ref=v2.0.0"

  global_prefix     = var.global_prefix
  environment       = var.environment
  environment_short = var.environment_short
  region            = var.region

  name                     = "f${var.name}"
  resource_group_name      = var.resource_group_name
  account_tier             = var.storage_account_info.account_tier
  account_replication_type = var.storage_account_info.account_replication_type
  access_tier              = var.storage_account_info.access_tier
}

module "app_service_plan" {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_app_service_plan?ref=v2.0.0"

  global_prefix     = var.global_prefix
  environment       = var.environment
  environment_short = var.environment_short
  region            = var.region

  name                = "f${var.name}"
  resource_group_name = var.resource_group_name
  kind                = var.app_service_plan_info.kind
  sku_tier            = var.app_service_plan_info.sku_tier
  sku_size            = var.app_service_plan_info.sku_size
}

resource "azurerm_function_app" "function_app" {
  name                      = local.resource_name
  resource_group_name       = var.resource_group_name
  location                  = var.region
  version                   = var.runtime_version
  app_service_plan_id       = module.app_service_plan.id
  storage_connection_string = module.storage_account.primary_connection_string

  site_config {
    min_tls_version = "1.2"
    ftps_state = "Disabled"
  }

  app_settings = merge(
    {
      APPINSIGHTS_INSTRUMENTATIONKEY = var.application_insights_instrumentation_key
    },
    var.app_settings
  )

  enable_builtin_logging = false

  tags = {
    environment = var.environment
  }
}

resource "azurerm_function_app" "function_app_monitor" {
  count = var.function_app_monitor.enable ? 1 : 0

  name                      = "${local.resource_name}-dfm"
  resource_group_name       = var.resource_group_name
  location                  = var.region
  version                   = var.runtime_version
  app_service_plan_id       = module.app_service_plan.id
  storage_connection_string = module.storage_account.primary_connection_string

  site_config {
    min_tls_version = "1.2"
    ftps_state = "Disabled"
  }

  app_settings = merge(
    {
      APPINSIGHTS_INSTRUMENTATIONKEY = var.application_insights_instrumentation_key
    },
    var.app_dfmonitor_settings
  )

  enable_builtin_logging = false

  tags = {
    environment = var.environment
  }
}

resource "azurerm_template_deployment" "function_keys" {
  count = var.export_default_key ? 1 : 0

  name  = "javafunckeys"
  parameters = {
    functionApp = azurerm_function_app.function_app.name
  }
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"

  template_body = <<BODY
  {
      "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
      "contentVersion": "1.0.0.0",
      "parameters": {
          "functionApp": {"type": "string", "defaultValue": ""}
      },
      "variables": {
          "functionAppId": "[resourceId('Microsoft.Web/sites', parameters('functionApp'))]"
      },
      "resources": [
      ],
      "outputs": {
          "functionkey": {
              "type": "string",
              "value": "[listkeys(concat(variables('functionAppId'), '/host/default'), '2018-11-01').functionKeys.default]"                                                                                }
      }
  }
  BODY
}
