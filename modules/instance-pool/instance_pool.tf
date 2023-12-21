terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
      version= ">=1.25.0"
    }
  }
}

data "databricks_spark_version" "lts_runtime" {
  long_term_support = true
  spark_version     = "3.4.1"
}

resource "databricks_instance_pool" "pools" {
  for_each = var.instance_pools

  lifecycle {
    ignore_changes = [ preloaded_spark_versions ]
  }

  instance_pool_name      = each.value.name
  min_idle_instances      = each.value.min_idle_instances
  max_capacity            = each.value.max_capacity
  node_type_id            = each.value.node_type_id
  idle_instance_autotermination_minutes = each.value.auto_termination_min
  preloaded_spark_versions = [
    data.databricks_spark_version.lts_runtime.id
  ]
}

resource "databricks_permissions" "pool" {
  for_each = var.instance_pools

  instance_pool_id = databricks_instance_pool.pools[each.key].id

  dynamic access_control {
    for_each = each.value.group_permissions
    content{
      group_name       = access_control.value.group_name
      permission_level = access_control.value.permission_level
    }
  }

  dynamic access_control {
    for_each = each.value.user_permissions
    content{
      service_principal_name  = var.service_principals[access_control.value.principal].application_id
      permission_level        = access_control.value.permission_level
    }
  }
}
