variable "service_principals" {
  type = map(object({
    application_id  = string
    display_name    = string
  }))
}

variable "shared_sql_endpoint" {
  type = object({
    name                  = string
    cluster_size          = string
    warehouse_type        = string
    min_num_clusters      = number
    max_num_clusters      = number
    auto_stop_mins        = number
    spot_instance_policy  = string
    group_permissions   = list(object({
      group_name        = string
      permission_level  = string
    }))

    user_permissions   = list(object({
      principal        = string
      permission_level = string
    }))
  })

  default = {
    name         = "shared"
    cluster_size = "Medium"
    warehouse_type = "PRO"
    min_num_clusters = 1
    max_num_clusters = 1
    auto_stop_mins   = 15
    spot_instance_policy = "COST_OPTIMIZED"
    group_permissions     = []
    user_permissions      = []
  }
}

variable "shared_sql_endpoint_enabled" {
  type        = bool
  description = "Whether create a new SQL warehosue or not? It should only created on primary region"
  default     = false
}

variable "sql_data_access_config" {
  type = map(object({
    client_id_scope        = string
    client_secret_scope    = string
    bi_sa                  = string
    bi_sa_key_secret_scope = string
  }))
}

variable "sql_query_privileges" {
  type = map(string)
  description = "Grant the user group and service principal to the sql endpoint schemas"
}
