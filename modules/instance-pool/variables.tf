variable "service_principals" {
  type = map(object({
    application_id  = string
    display_name    = string
  }))
}

variable "instance_pools" {
  type = map(object({
    name = string
    min_idle_instances    = number
    max_capacity          = number
    node_type_id = string
    auto_termination_min  = number

    group_permissions = list(object({
      group_name          = string
      permission_level    = string
    }))

    user_permissions = list(object({
      principal          = string
      permission_level    = string
    }))
  }))

  description = "Define the instance pools"
}
