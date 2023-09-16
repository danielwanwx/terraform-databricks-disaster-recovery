output "databricks_workspace_url" {
  value = azurerm_databricks_workspace.workspace.workspace_url
}

output "databricks_workspace_resource_id" {
  value = azurerm_databricks_workspace.workspace.id
}
