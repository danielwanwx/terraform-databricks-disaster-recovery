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
  spark_version     = "13.3.x-scala2.12"
}

data "databricks_service_principal" "spns" {
  for_each       = var.service_principals
  application_id = each.value.application_id
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

resource "databricks_permissions" "pool_group_permissions" {
  for_each = var.instance_pools

  instance_pool_id = databricks_instance_pool.pools[each.key].id

  dynamic access_control {
    for_each = each.value.group_permissions
    content{
      group_name       = access_control.value.group_name
      permission_level = access_control.value.permission_level
    }
  }
}

resource "databricks_permissions" "pool_user_permissions" {
  for_each         = var.instance_pools
  instance_pool_id = databricks_instance_pool.pools[each.key].id

  dynamic access_control {
    for_each = each.value.user_permissions
    content{
      service_principal_name  = data.databricks_service_principal.spns[access_control.value.principal].application_id
      permission_level        = access_control.value.permission_level
    }
  }
}