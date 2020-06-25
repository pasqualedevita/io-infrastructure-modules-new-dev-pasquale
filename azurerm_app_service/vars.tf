variable "global_prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "environment_short" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "app_service_plan_info" {
  type = object({
    kind     = string
    sku_tier = string
    sku_size = string
  })

  default = {
    kind     = "elastic"
    sku_tier = "ElasticPremium"
    sku_size = "EP1"
  }
}

variable "app_enabled" {
  type        = bool
  description = "Is the App Service Enabled?"
  default     = true
}

variable "client_cert_enabled" {
  type    = bool
  default = false
}

variable "https_only" {
  type    = bool
  default = true
}

variable "application_insights_instrumentation_key" {
  type = string
}

variable "app_settings" {
  type    = map(any)
  default = {}
}

variable "app_settings_secrets" {
  type = object({
    key_vault_id = string
    map          = map(string)
  })
}

variable "always_on" {
  type    = bool
  default = true
}

locals {
  resource_name = "${var.global_prefix}-${var.environment_short}-app-${var.name}"
}
