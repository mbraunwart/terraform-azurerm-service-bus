resource "azurerm_servicebus_namespace" "sb_ns" {
  name                          = var.servicebus_namespace.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.servicebus_namespace.sku
  capacity                      = var.servicebus_namespace.capacity
  public_network_access_enabled = false
  premium_messaging_partitions  = var.servicebus_namespace.premium_messaging_partitions

  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, { "service" = "service_bus" })
}

resource "azurerm_servicebus_namespace_authorization_rule" "send_only" {
  count        = !var.servicebus_namespace.auth_rules.manage && var.servicebus_namespace.auth_rules.send ? 1 : 0
  name         = format("%s-send", var.servicebus_namespace.name)
  namespace_id = azurerm_servicebus_namespace.sb_ns.id
  send         = true
}

resource "azurerm_servicebus_namespace_authorization_rule" "listen_only" {
  count        = !var.servicebus_namespace.auth_rules.manage && var.servicebus_namespace.auth_rules.listen ? 1 : 0
  name         = format("%s-listen", var.servicebus_namespace.name)
  namespace_id = azurerm_servicebus_namespace.sb_ns.id
  listen       = true
}

resource "azurerm_servicebus_namespace_authorization_rule" "manage_only" {
  count        = var.servicebus_namespace.auth_rules.manage ? 1 : 0
  name         = format("%s-manage", var.servicebus_namespace.name)
  namespace_id = azurerm_servicebus_namespace.sb_ns.id
  send         = true
  listen       = true
  manage       = true
}

resource "azurerm_monitor_diagnostic_setting" "sb_diag" {
  name                       = "servicebus-diag"
  target_resource_id         = azurerm_servicebus_namespace.sb_ns.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
