resource "azurerm_servicebus_queue" "dead_letter_queue" {
  count        = local.storage_enabled && local.containers.dead_letter != null ? 1 : 0
  name         = "dead-letter-queue"
  namespace_id = azurerm_servicebus_namespace.sb_ns.id

  max_delivery_count            = 1
  max_message_size_in_kilobytes = 1024

  default_message_ttl = format("P%dD", local.containers.dead_letter.ttl_days)
}

resource "azurerm_automation_account" "message_transfer" {
  count               = local.storage_enabled && local.containers.dead_letter != null ? 1 : 0
  name                = "sb-message-transfer"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, { "service" = "dead letter queue automation" })
}

resource "azurerm_role_assignment" "automation_storage" {
  count                = local.storage_enabled && local.containers.dead_letter != null ? 1 : 0
  scope                = var.storage_configuration.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_automation_account.message_transfer[0].identity[0].principal_id
}

resource "azurerm_role_assignment" "automation_servicebus" {
  count                = local.storage_enabled && local.containers.dead_letter != null ? 1 : 0
  scope                = azurerm_servicebus_namespace.sb_ns.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = azurerm_automation_account.message_transfer[0].identity[0].principal_id
}
