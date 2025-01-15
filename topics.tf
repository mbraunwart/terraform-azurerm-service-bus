resource "azurerm_servicebus_topic" "sb_topic" {
  for_each     = { for topic in var.servicebus_topics : topic.name => topic }
  name         = each.value.name
  namespace_id = azurerm_servicebus_namespace.sb_ns.id

  max_message_size_in_kilobytes = each.value.max_message_size_in_kilobytes
  max_size_in_megabytes         = each.value.max_size_in_megabytes

  depends_on = [azurerm_storage_container.c]
}

resource "azurerm_servicebus_subscription" "sb_sub" {
  for_each = { for topic in var.servicebus_topics : topic.name => topic }
  name     = azurerm_servicebus_topic.sb_topic[each.key].name
  topic_id = azurerm_servicebus_topic.sb_topic[each.key].id

  max_delivery_count = each.value.max_delivery_count

  depends_on = [azurerm_servicebus_topic.sb_topic]
}

resource "azurerm_servicebus_topic_authorization_rule" "send_only" {
  for_each = { for topic in var.servicebus_topics : topic.name => topic
  if topic.auth_rules != null && !topic.auth_rules.manage && topic.auth_rules.send }

  name     = format("%s-send", each.value.name)
  topic_id = azurerm_servicebus_topic.sb_topic[each.key].id

  send = true
}

resource "azurerm_servicebus_topic_authorization_rule" "listen_only" {
  for_each = { for topic in var.servicebus_topics : topic.name => topic
  if topic.auth_rules != null && !topic.auth_rules.manage && topic.auth_rules.listen }

  name     = format("%s-listen", each.value.name)
  topic_id = azurerm_servicebus_topic.sb_topic[each.key].id

  listen = true
}

resource "azurerm_servicebus_topic_authorization_rule" "manage_only" {
  for_each = { for topic in var.servicebus_topics : topic.name => topic
  if topic.auth_rules != null && topic.auth_rules.manage }

  name     = format("%s-manage", each.value.name)
  topic_id = azurerm_servicebus_topic.sb_topic[each.key].id

  send   = true
  listen = true
  manage = true
}