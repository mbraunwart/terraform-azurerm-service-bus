locals {
  storage_enabled = var.storage_configuration.enabled
  containers      = var.storage_configuration.containers
}

# Consolidated container resources
resource "azurerm_storage_container" "c" {
  for_each = local.storage_enabled ? {
    service_bus   = local.containers.service_bus
    dead_letter   = local.containers.dead_letter
    session_state = local.containers.session_state
  } : {}

  name                  = each.value.name
  container_access_type = each.value.access_type
  storage_account_id    = var.storage_configuration.storage_account_id
}

resource "azurerm_role_assignment" "container_access" {
  for_each = local.storage_enabled ? {
    service_bus   = local.containers.service_bus
    dead_letter   = local.containers.dead_letter
    session_state = local.containers.session_state
  } : {}
  scope                = azurerm_storage_container.c["service_bus"].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_servicebus_namespace.sb_ns.identity[0].principal_id
}

resource "azurerm_storage_management_policy" "deadletter_lifecycle" {
  count              = local.storage_enabled && local.containers.dead_letter != null ? 1 : 0
  storage_account_id = var.storage_configuration.storage_account_id

  rule {
    name    = "deadLetterExpiration"
    enabled = true
    filters {
      prefix_match = [local.containers.dead_letter.name]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = local.containers.dead_letter.ttl_days
      }
    }
  }
}
