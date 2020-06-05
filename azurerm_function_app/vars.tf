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

variable "runtime_version" {
  type    = string
  default = "~2"
}

variable "storage_account_info" {
  type = object({
    account_tier             = string
    account_replication_type = string
    access_tier              = string
  })

  default = {
    account_tier             = "Standard"
    account_replication_type = "LRS"
    access_tier              = "Hot"
  }
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

variable "function_app_monitor" {
  type = object({
    enable  = bool
  })

  default = {
    enable = false
  }
}

variable application_insights_instrumentation_key {
  type = string
}

variable app_settings {
  type = map(any)

  default = {}
}

variable app_dfmonitor_settings {
  type = map(any)

  default = {}
}

variable export_default_key {
  type    = bool
  default = false
}

locals {
  resource_name = "${var.global_prefix}-${var.environment_short}-func-${var.name}"
}
