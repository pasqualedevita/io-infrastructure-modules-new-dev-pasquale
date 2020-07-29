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

variable "workflow_schema" {
  type    = string
  default = null
}

variable "workflow_version" {
  type    = string
  default = null
}

locals {
  resource_name = "${var.global_prefix}-${var.environment_short}-lapp-${var.name}"
}
