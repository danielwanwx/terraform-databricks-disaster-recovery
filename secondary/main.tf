# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
    databricks = {
      source = "databricks/databricks"
      version= ">=1.25.0"
    }
  }

  # Backend Configuration
  backend "azurerm" {
  }

  # Required Terraform Version
  required_version = ">=1.1"
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Configure the Databricks Provider
provider "databricks" {
  host                        = module.workspace.databricks_workspace_url
  azure_workspace_resource_id = module.workspace.databricks_workspace_resource_id
  azure_client_id             = var.client_id
  azure_client_secret         = var.client_secret
  azure_tenant_id             = var.tenant_id
}

# Use the "workspace" module
module "workspace" {
  source = "../modules/workspace"

  # Input variables
  resource_group_name         = var.resource_group_name
  location                    = var.location
  vnet_name                   = var.vnet_name
  vnet_resource_group_name    = var.vnet_resource_group_name
  public_subnet_name          = var.public_subnet_name
  private_subnet_name         = var.private_subnet_name
  databricks_name             = var.databricks_name
  sku                         = var.sku
  managed_resource_group_name = var.managed_resource_group_name
  storage_account_name        = var.storage_account_name

  # Tags
  tags = merge(var.common_tags, {
    "BCDR" = true
  })
}
