output "service_principals" {
  value = {
    for name, item in databricks_service_principal.service_principals:
      name => {
        application_id = item.application_id
        display_name   = item.display_name
      }
  }
}
