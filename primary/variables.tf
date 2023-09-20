variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource has to be created"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Azure resource group"
}

variable "vnet_name" {
  type        = string
  description = "Name of the spoke virtual network"
}

variable "vnet_resource_group_name" {
  type        = string
  description = "Name of the resource group containing the virtual network"
}

variable "public_subnet_name" {
  type        = string
  description = "Name of the public subnet"
}

variable "private_subnet_name" {
  type        = string
  description = "Name of the private subnet"
}

variable "databricks_name" {
  type        = string
  description = "Name of the Databricks resource"
}

variable "sku" {
  type        = string
  description = "SKU of the resource"
}

variable "managed_resource_group_name" {
  type        = string
  description = "Name of the managed resource group"
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "client_id" {
  type        = string
  description = "Azure client ID"
}

variable "client_secret" {
  type        = string
  description = "Azure client secret"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to resources"
}

variable "service_principals" {
  type = map(object({
    application_id  = string
    display_name    = string
  }))
}
variable "instance_pools" {
  type = map(object({
    name = string
    min_idle_instances    = number
    max_capacity          = number
    node_type_id          = string
    auto_termination_min  = number

    group_permissions = list(object({
      group_name          = string
      permission_level    = string
    }))

    user_permissions = list(object({
      principal          = string
      permission_level    = string
    }))
  }))

  description = "Define the instance pools"
}
