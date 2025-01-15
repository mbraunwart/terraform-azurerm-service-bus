# Namespace outputs
output "namespace_id" {
  description = "The Service Bus Namespace ID"
  value       = azurerm_servicebus_namespace.sb_ns.id
}

output "namespace_name" {
  description = "The Service Bus Namespace name"
  value       = azurerm_servicebus_namespace.sb_ns.name
}

output "namespace_endpoint" {
  description = "The Service Bus Namespace endpoint"
  value       = azurerm_servicebus_namespace.sb_ns.endpoint
}

output "primary_connection_string" {
  description = "The primary connection string for the Service Bus namespace"
  value       = azurerm_servicebus_namespace.sb_ns.default_primary_connection_string
  sensitive   = true
}

output "secondary_connection_string" {
  description = "The secondary connection string for the Service Bus namespace"
  value       = azurerm_servicebus_namespace.sb_ns.default_secondary_connection_string
  sensitive   = true
}

output "primary_key" {
  description = "The primary key for the Service Bus namespace"
  value       = azurerm_servicebus_namespace.sb_ns.default_primary_key
  sensitive   = true
}

output "secondary_key" {
  description = "The secondary key for the Service Bus namespace"
  value       = azurerm_servicebus_namespace.sb_ns.default_secondary_key
  sensitive   = true
}

# Queue outputs
output "queue_ids" {
  description = "Map of queue names to their IDs"
  value       = { for k, v in azurerm_servicebus_queue.sb_queue : k => v.id }
}

output "queue_names" {
  description = "List of created queue names"
  value       = values(azurerm_servicebus_queue.sb_queue)[*].name
}

output "dead_letter_queue" {
  description = "Dead letter queue details"
  value = local.storage_enabled && local.containers.dead_letter != null ? {
    id   = azurerm_servicebus_queue.dead_letter_queue[0].id
    name = azurerm_servicebus_queue.dead_letter_queue[0].name
  } : null
}

output "automation_account" {
  description = "Automation account for message transfer"
  value = local.storage_enabled && local.containers.dead_letter != null ? {
    id           = azurerm_automation_account.message_transfer[0].id
    name         = azurerm_automation_account.message_transfer[0].name
    principal_id = azurerm_automation_account.message_transfer[0].identity[0].principal_id
  } : null
}

# Storage integration outputs
output "storage_containers" {
  description = "Map of storage container names to their properties"
  value = local.storage_enabled ? {
    for k, v in azurerm_storage_container.c : k => {
      name = v.name
      id   = v.id
    }
  } : null
}

# Identity outputs
output "managed_identity" {
  description = "The managed identity of the Service Bus namespace"
  value = {
    principal_id = azurerm_servicebus_namespace.sb_ns.identity[0].principal_id
    tenant_id    = azurerm_servicebus_namespace.sb_ns.identity[0].tenant_id
  }
}

# Topic outputs
output "topic_ids" {
  description = "Map of topic names to their IDs"
  value       = { for k, v in azurerm_servicebus_topic.sb_topic : k => v.id }
}

output "topic_names" {
  description = "List of created topic names"
  value       = values(azurerm_servicebus_topic.sb_topic)[*].name
}

# Diagnostic settings outputs
output "diagnostic_setting_id" {
  description = "The ID of the diagnostic setting"
  value       = azurerm_monitor_diagnostic_setting.sb_diag.id
}

output "diagnostic_setting_name" {
  description = "The name of the diagnostic setting"
  value       = azurerm_monitor_diagnostic_setting.sb_diag.name
}
