variable "resource_group_name" {
  type        = string
  description = "Resource group name in Azure"
}

variable "location" {
  type        = string
  description = "Resource group location in Azure"
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Log Analytics Workspace name"
}

variable "tags" {
  type        = map(string)
  description = "tags"
  default     = {}
}

variable "diag_setting_target_resource_id" {
  type = string
  description = "the target resource id"
}

variable "diagnostic_logs" {
  type = list(string)
  description = "Logs for Diagnostic Settings"
  default = []
}
