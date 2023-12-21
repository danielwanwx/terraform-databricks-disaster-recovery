terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
      version= ">=1.25.0"
    }
  }
}

# Create the shared sql_endpoint
resource "databricks_sql_endpoint" "shared" {
  count                = var.shared_sql_endpoint_enabled ? 1 : 0

  name                 = var.shared_sql_endpoint.name
  cluster_size         = var.shared_sql_endpoint.cluster_size
  max_num_clusters     = var.shared_sql_endpoint.max_num_clusters
  auto_stop_mins       = var.shared_sql_endpoint.auto_stop_mins
  spot_instance_policy = var.shared_sql_endpoint.spot_instance_policy
  warehouse_type       = var.shared_sql_endpoint.warehouse_type
}

# Grant users or service principal to the shared sql endpoint
resource "databricks_permissions" "shared_sql" {
  count                = var.shared_sql_endpoint_enabled ? 1 : 0
  sql_endpoint_id      = databricks_sql_endpoint.shared[0].id

  dynamic access_control {
    for_each = var.shared_sql_endpoint.user_permissions
    content{
      service_principal_name  = var.service_principals[access_control.value.principal].application_id
      permission_level        = access_control.value.permission_level
    }
  }

  dynamic access_control {
    for_each = var.shared_sql_endpoint.group_permissions
    content{
      group_name       = access_control.value.group_name
      permission_level = access_control.value.permission_level
    }
  }
}

locals {
  data_access_config_per_sa = {
    for sa, item in var.sql_data_access_config:
      sa => {
      }
  }
  data_access_config = merge(values(local.data_access_config_per_sa)...)

  database_privileges = var.shared_sql_endpoint_enabled ? {
    for schema_prefix, spn_name in var.sql_query_privileges:
      schema_prefix => var.service_principals[spn_name].application_id
  } : {}
}

resource "databricks_sql_global_config" "config" {
  security_policy   = "DATA_ACCESS_CONTROL"
  data_access_config = local.data_access_config
  sql_config_params = {
    "ANSI_MODE" : "true"
  }
}

resource "databricks_sql_query" "privileges_sql_query" {
  for_each        = local.database_privileges
  data_source_id  = databricks_sql_endpoint.shared[0].data_source_id
  name            = "grant_database_privileges_${each.key}"
  query           = <<EOT
    -- general
    GRANT USAGE, SELECT, READ_METADATA ON SCHEMA ${each.key}_general TO `xx`;
    GRANT ALL PRIVILEGES ON SCHEMA ${each.key}_general TO `xx`;
    -- raw zone
    GRANT USAGE, SELECT, READ_METADATA ON SCHEMA ${each.key}_raw TO `xx`;
    GRANT USAGE, SELECT, READ_METADATA ON SCHEMA ${each.key}_raw TO `xx`;
  EOT
  run_as_role = "viewer"
}

resource "databricks_permissions" "database_privileges_permissions" {
  for_each        = local.database_privileges
  sql_query_id    = databricks_sql_query.privileges_sql_query[each.key].id

  access_control {
    group_name        = "bna-group-data-query"
    permission_level  = "CAN_RUN"
  }
}
