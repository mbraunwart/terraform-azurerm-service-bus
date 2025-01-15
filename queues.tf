resource "azurerm_servicebus_queue" "sb_queue" {
  for_each     = { for queue in var.servicebus_queues : queue.name => queue }
  name         = each.value.name
  namespace_id = azurerm_servicebus_namespace.sb_ns.id

  requires_session = local.storage_enabled && local.containers.session_state != null

  lock_duration                 = "PT30S"
  max_delivery_count            = each.value.max_delivery_count
  max_message_size_in_kilobytes = each.value.max_message_size_in_kilobytes
  max_size_in_megabytes         = each.value.max_size_in_megabytes

  dead_lettering_on_message_expiration = true
  forward_dead_lettered_messages_to    = local.storage_enabled && local.containers.dead_letter != null ? azurerm_servicebus_queue.dead_letter_queue[0].name : null

  depends_on = [azurerm_storage_container.c]
}

resource "azurerm_servicebus_queue_authorization_rule" "send_only" {
  for_each = { for queue in var.servicebus_queues : queue.name => queue
  if queue.auth_rules != null && !queue.auth_rules.manage && queue.auth_rules.send }

  name     = format("%s-send", each.value.name)
  queue_id = azurerm_servicebus_queue.sb_queue[each.key].id

  send = true
}

resource "azurerm_servicebus_queue_authorization_rule" "listen_only" {
  for_each = { for queue in var.servicebus_queues : queue.name => queue
  if queue.auth_rules != null && !queue.auth_rules.manage && queue.auth_rules.listen }

  name     = format("%s-listen", each.value.name)
  queue_id = azurerm_servicebus_queue.sb_queue[each.key].id

  listen = true
}

resource "azurerm_servicebus_queue_authorization_rule" "manage_only" {
  for_each = { for queue in var.servicebus_queues : queue.name => queue
  if queue.auth_rules != null && queue.auth_rules.manage }

  name     = format("%s-manage", each.value.name)
  queue_id = azurerm_servicebus_queue.sb_queue[each.key].id

  send   = true
  listen = true
  manage = true
}
