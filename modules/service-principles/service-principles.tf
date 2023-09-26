terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
      version= ">=1.25.0"
    }
  }
}

# get admins group
data "databricks_group" "admins"{
  display_name = "admins"
}

# get key vault secret to create secret scope
data "azurerm_key_vault" "key_vaults" {
  for_each = toset(values(var.keyvault_secret))
  name     = each.key
  resource_group_name = var.keyvault_resource_group
}

locals {

  group_members = flatten(concat([
    for group, item in var.databricks_groups: [
      for member in item.members: {
        group = group
        member = member
      }
    ]
  ]))

  secret_acls = flatten(concat([
    for scope, acls in var.secret_scope_acls: [
      for acl in acls: merge(acl, {
        scope = scope
      })
    ]
  ]))
}

resource "databricks_workspace_conf" "config" {
  custom_config = {
    enableTokensConfig      = true
    enableDbfsFileBrowser   = true
    # enableIpAccessLists     = true
  }
}

resource "databricks_user" "admins"{
  for_each = {
    for index, email in var.admin_user:
      email => email
  }
  user_name = each.value
}

# create group
resource "databricks_group" "groups" {
  for_each      = var.databricks_groups
  display_name  = each.value.name
}

resource "databricks_group_member" "admins" {
  for_each  = {
    for index, email in var.admin_user:
      email => email
  }
  member_id  = databricks_user.admins[each.value].id
  group_id   = data.databricks_group.admins.id
}

resource "databricks_group_member" "group_members" {
  for_each = {
    for index, item in local.group_members:
      "${item.group}-${item.member}" => item
  }
  group_id  = databricks_group.groups[each.value.group].id
  member_id = databricks_service_principal.spns[each.value.member].id
}

resource "databricks_service_principal" "service_principals" {
  for_each        = var.service_principals
  application_id   = each.value.application_id
  display_name     = each.value.display_name

  allow_cluster_create  = lookup(each.value, "allow_cluster_create", false)
  databricks_sql_access = lookup(each.value, "databricks_sql_access", false)
  workspace_access      = lookup(each.value, "workspace_access", false)

}

resource "databricks_secret_scope" "scopes" {
  for_each = var.keyvault_secret
  name = each.key
  keyvault_metadata {
    resource_id = data.azurerm_key_vault.key_vaults[each.value].id
    dns_name    = data.azurerm_key_vault.key_vaults[each.value].vault_uri
  }
}

# create secret access list
resource "databricks_secret_acl" "acls" {
  for_each = {
    for index, acl in local.secret_acls:
      "${acl.scope}-${acl.principal}" => acl
  }
  principal  = each.value.type == "group" ? databricks_group.groups[each.value.principal].display_name : databricks_service_principal.service_principals[each.value.principal].application_id
  permission = each.value.permission
  scope      = each.value.scope
  depends_on = [
    databricks_secret_scope.scopes
  ]
}
