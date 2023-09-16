variable "resource_group_name" {
  type = string
  description = "resource group name"
}

variable "location" {
  type = string
  description = "Specifies the supported Azure location where the resource has to be created"
}

variable "vnet_resource_group_name" {
  type        = string
  description = "value"
}
variable "vnet_name" {
  type        = string
  description = "The vnet name from analytics Virtual Network"
}

variable "public_subnet_name" {
  type        = string
  description = "The name of the Public Subnet within the Virtual Network"
}

variable "private_subnet_name" {
  type        = string
  description = "The name of the Private Subnet within the Virtual Network"
}

variable "databricks_name" {
  type        = string
  description = "Specifies the name of the Databricks Workspace resource"
}

variable "sku" {
  type        = string
  description = "The sku to use for the Databricks Workspace. Possible values are standard, premium, or trial."
}

variable "managed_resource_group_name" {
  type        = string
  description = "The name of the resource group where Azure should place the managed Databricks resources"
}

variable "storage_account_name" {
  type        = string
  description = "Default Databricks File Storage account name. Defaults to a randomized name"
}

variable "tags" {
  type        = map(string)
  description = "tags"
  default     = {}
}
