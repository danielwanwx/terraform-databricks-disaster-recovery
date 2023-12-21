terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
      version= ">=1.25.0"
    }
  }
}

data "databricks_group" "admins" {
  display_name = "admins"
}

data "azurerm_key_vault" "key_vaults" {
  for_each = toset(values(var.keyvault_secret))
  name     = each.key
  resource_group_name = var.keyvault_rg_name
}

resource "databricks_workspace_conf" "config" {
  custom_config = {
    enableTokensConfig      = true
    enableDbfsFileBrowser   = true
    # enableIpAccessLists     = true
  }
}

resource "databricks_user" "admins" {
  for_each  = {
    for index, email in var.admin_usernames:
      email => email
  }
  user_name = each.value
}

resource "databricks_group_member" "admins" {
  for_each  = {
    for index, email in var.admin_usernames:
      email => email
  }
  member_id  = databricks_user.admins[each.value].id
  group_id   = data.databricks_group.admins.id
}

resource "databricks_group" "groups" {
  for_each      = var.databricks_groups
  display_name  = each.value.name
}

resource "databricks_service_principal" "spns" {
  for_each         = var.service_principals
  application_id   = each.value.application_id
  display_name     = each.value.display_name

  allow_cluster_create  = lookup(each.value, "allow_cluster_create", false)
  databricks_sql_access = lookup(each.value, "databricks_sql_access", false)
  workspace_access      = lookup(each.value, "workspace_access", false)
  force                 = lookup(each.value, "force", false)
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

resource "databricks_secret_scope" "scopes" {
  for_each = var.keyvault_secret
  name = each.key
  keyvault_metadata {
    resource_id = data.azurerm_key_vault.key_vaults[each.value].id
    dns_name    = data.azurerm_key_vault.key_vaults[each.value].vault_uri
  }
}

resource "databricks_group_member" "group_members" {
  for_each = {
    for index, item in local.group_members:
      "${item.group}-${item.member}" => item
  }
  group_id  = databricks_group.groups[each.value.group].id
  member_id = databricks_service_principal.spns[each.value.member].id
}

resource "time_rotating" "this" {
  rotation_days = 30
}

# Token permissions can be set only if at least one token has been created in the workspace.
resource "databricks_token" "pat" {
  comment = "Terraform (created: ${time_rotating.this.rfc3339})"

  # Token is valid for 60 days but is rotated after 30 days.
  lifetime_seconds = 60 * 24 * 60 * 60
}


resource "databricks_secret_acl" "acls" {
  for_each = {
    for index, acl in local.secret_acls:
      "${acl.scope}-${acl.principal}" => acl
  }
  principal  = each.value.type == "group" ? databricks_group.groups[each.value.principal].display_name : databricks_service_principal.spns[each.value.principal].application_id
  permission = each.value.permission
  scope      = each.value.scope
  depends_on = [
    databricks_secret_scope.scopes
  ]
}

resource "databricks_permissions" "token_usage" {
  authorization = "tokens"

  dynamic access_control {
    for_each = var.token_usage_acl.group_permissions
    content{
      group_name       = access_control.value.group_name
      permission_level = access_control.value.permission_level
    }
  }

  dynamic access_control {
    for_each = var.token_usage_acl.user_permissions
    content{
      service_principal_name  = var.service_principals[access_control.value.principal].application_id
      permission_level        = access_control.value.permission_level
    }
  }

}
