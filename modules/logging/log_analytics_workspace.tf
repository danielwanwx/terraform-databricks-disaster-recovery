resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.log_analytics_workspace_name}-${var.location}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "setting" {
  name                        = "${var.log_analytics_workspace_name}-setting-${var.location}"
  target_resource_id          = var.diag_setting_target_resource_id
  log_analytics_workspace_id  = azurerm_log_analytics_workspace.law.id

  dynamic enabled_log {
    for_each = sort(var.diagnostic_logs)
    content {
      category = enabled_log.value
    }
  }
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.law.id
}

output "log_analytics_workspace_setting_id" {
  value = azurerm_monitor_diagnostic_setting.setting.id
}
