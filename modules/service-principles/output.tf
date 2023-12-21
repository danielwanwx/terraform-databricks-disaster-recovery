output "service_principals" {
  value = {
    for name, item in databricks_service_principal.spns:
      name => {
        application_id = item.application_id
        display_name   = item.display_name
      }
  }
}
