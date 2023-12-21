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

#prv and dev
resource "databricks_cluster" "notebookdev" {
  for_each = var.notebook_shared_enabled ? toset(["1"]) : []

  is_pinned               = true
  cluster_name            = var.notebookdev_cluster.cluster_name
  spark_version           = data.databricks_spark_version.lts_runtime.id
  node_type_id            = var.notebookdev_cluster.node_type_id
  driver_node_type_id     = var.notebookdev_cluster.driver_node_type_id
  autotermination_minutes = var.notebookdev_cluster.autotermination_minutes
  enable_elastic_disk     = true
  enable_local_disk_encryption = false
  data_security_mode      = "NONE"
  runtime_engine          = "STANDARD"
  autoscale {
    min_workers = var.notebookdev_cluster.min_workers
    max_workers = var.notebookdev_cluster.max_workers
  }
  azure_attributes {
    first_on_demand      = 1
    availability        = "ON_DEMAND_AZURE"
    spot_bid_max_price  = -1
  }
}

resource "databricks_permissions" "notebookdev" {
  for_each = var.notebook_shared_enabled ? toset(["1"]) : []

  cluster_id = databricks_cluster.notebookdev[each.key].id

  dynamic access_control {
    for_each = var.notebookdev_cluster.group_permissions
    content{
      group_name        = access_control.value.group_name
      permission_level  = access_control.value.permission_level
    }
  }

  dynamic access_control {
    for_each = var.notebookdev_cluster.user_permissions
    content{
      service_principal_name  = var.service_principals[access_control.value.principal].application_id
      permission_level        = access_control.value.permission_level
    }
  }
}

resource "databricks_library" "lib_sqlkafka" {
  for_each    = var.notebook_shared_enabled ? toset(["1"]) : []
  cluster_id  = databricks_cluster.notebookdev[each.key].id
  maven {
    coordinates = "org.apache.spark:spark-sql-kafka-0-10_2.12:3.4.1"
  }
}

resource "databricks_library" "lib_nutter" {
  for_each    = var.notebook_shared_enabled ? toset(["1"]) : []
  cluster_id  = databricks_cluster.notebookdev[each.key].id
  pypi {
    package = "nutter==0.1.35"
  }
}
