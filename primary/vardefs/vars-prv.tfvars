location = "East US"
resource_group_name = "my-resource-group"
spoke_vnet_name = "spoke-vnet"
vnet_resource_group_name = "vnet-resource-group"
public_subnet_name = "public-subnet"
private_subnet_name = "private-subnet"
databricks_name = "my-databricks"
sku = "premium"
managed_resource_group_name = "managed-rg"
storage_account_name = "mystorageaccount"
subscription_id = "your-subscription-id"
client_id = "your-client-id"
client_secret = "your-client-secret"
tenant_id = "your-tenant-id"
service_principals = {
  job = {
    application_id  = "111111111111111111111"
    display_name    = "job"
  }
  infra = {
    application_id  = "111111111111111111111"
    display_name    = "infra"
  }
}

# Instance Pools
instance_pools = {
  streaming = {
    name                  = "demo-prv-streaming"
    min_idle_instances    = 1
    max_capacity          = 1
    node_type_id          = "Standard_D4a_v4"
    auto_termination_min  = 5
    group_permissions = [
      {
        group_name       = "admin"
        permission_level = "CAN_MANAGE"
      }
    ]
    user_permissions = [
      {
        principal         = "job"
        permission_level  = "CAN_ATTACH_TO"
      }
    ]
  }
  shared = {
    name                  = "demo-prv-test"
    min_idle_instances    = 0
    max_capacity          = 2
    node_type_id          = "Standard_D4a_v4"
    auto_termination_min  = 10
    group_permissions = [
      {
        group_name        = "group-job"
        permission_level  = "CAN_ATTACH_TO"
      }
    ]
    user_permissions = [
      {
        principal         = "job"
        permission_level  = "CAN_ATTACH_TO"
      }
    ]
  }
}
