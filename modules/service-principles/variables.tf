variable "databricks_groups" {
  type = map(object({
    name = string
    members = list(string)
  }))
}

variable "service_principals" {
  type = map(object({
    application_id  = string
    display_name    = string
    allow_cluster_create  = optional(bool)
    databricks_sql_access = optional(bool)
    workspace_access = optional(bool)
    force = optional(bool)
  }))
}

variable "secret_scope_acls" {
  type = map(list(object({
    type        = string
    principal   = string
    permission  = string
  })))
  description = "The secret scope acl mappings"
}

variable "keyvault_rg_name" {
  type        = string
  description = "key vault resource group name"
}

variable "keyvault_secret" {
  type    = map(string)
  description = "key vault secret for create databricks's scope"
}
variable "admin_usernames" {
  type        = list(string)
  description = "admin users"
}

variable "token_usage_acl" {
  type = object({
    group_permissions   = list(object({
      group_name        = string
      permission_level  = string
    }))

    user_permissions   = list(object({
      principal        = string
      permission_level = string
    }))
  })
}
