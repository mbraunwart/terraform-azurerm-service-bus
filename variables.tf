variable "resource_group_name" {
  description = "The name of the resource group in which the key vault should be created."
  type        = string
}

variable "location" {
  description = "The location/region where the key vault should be created."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  type        = string
  default     = ""
}

variable "servicebus_namespace" {
  description = "The Service Bus namespace configuration."
  type = object({
    name                         = string
    sku                          = optional(string, "Premium")
    capacity                     = optional(number, 1)
    premium_messaging_partitions = optional(number, 1)
    auth_rules = object({
      send   = optional(bool, false)
      listen = optional(bool, false)
      manage = optional(bool, false)
    })
  })
}

variable "servicebus_queues" {
  description = "The name of the Service Bus queue."
  type = list(object({
    name                          = string
    max_message_size_in_kilobytes = optional(number, 1024)
    max_delivery_count            = optional(number, 30)
    auth_rules = optional(object({
      send   = optional(bool, false)
      listen = optional(bool, false)
      manage = optional(bool, false)
    }))
  }))
  default = []
}

variable "servicebus_topics" {
  description = "The name of the Service Bus topic."
  type = list(object({
    name                          = string
    max_message_size_in_kilobytes = optional(number, 1024)
    max_size_in_megabytes         = optional(number, 5120)
    max_delivery_count            = optional(number, 30)
    auth_rules = optional(object({
      send   = optional(bool, false)
      listen = optional(bool, false)
      manage = optional(bool, false)
    }))
  }))
  default = []
}

variable "storage_configuration" {
  type = object({
    enabled            = bool
    storage_account_id = string
    containers = object({
      service_bus = optional(object({
        name        = string
        access_type = optional(string, "private")
      }), null)
      dead_letter = optional(object({
        name        = string
        access_type = optional(string, "private")
        ttl_days    = optional(number, 7)
      }), null)
      session_state = optional(object({
        name        = string
        access_type = optional(string, "private")
      }), null)
    })
  })
  description = "Storage account configuration for Service Bus features"
  default = {
    enabled            = false
    storage_account_id = null
    containers         = null
  }

  validation {
    condition     = var.storage_configuration.enabled == false || var.storage_configuration.storage_account_id != null
    error_message = "storage_account_id is required when storage is enabled"
  }

  validation {
    condition     = var.storage_configuration.enabled == false || var.storage_configuration.containers != null
    error_message = "At least one container configuration is required when storage is enabled"
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
