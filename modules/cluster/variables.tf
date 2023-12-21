variable "tags" {
  type        = map(string)
  description = "tags"
  default     = {}
}

variable "service_principals" {
  type = map(object({
    application_id  = string
    display_name    = string
  }))
}

variable "notebook_shared_enabled" {
  type        = bool
  description = "Whether to create all purpose shared cluster"
  default     = false
}
variable "notebookdev_cluster" {
  type = object({
    cluster_name            = string
    node_type_id            = string
    driver_node_type_id     = string
    autotermination_minutes = number
    min_workers             = number
    max_workers             = number
    group_permissions   = list(object({
      group_name        = string
      permission_level  = string
    }))

    user_permissions   = list(object({
      principal        = string
      permission_level = string
    }))
  })

  description = <<EOT
    notebookdev_setting = {
      cluster_name            = "Identifier for a cluster used in regular dev tasks"
      node_type_id            = "Node type id"
      driver_node_type_id     = "Driver node type id"
      autotermination_minutes = "Auto terminate the cluster in minutes"
      min_workers             = "Minimum number workers of streaming cluster"
      max_workers             = "Maximum number workers of streaming cluster"
    }
  EOT
}
