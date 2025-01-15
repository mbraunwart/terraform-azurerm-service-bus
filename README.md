---
title: "Azure Service Bus Infrastructure Module"
author: "Matt Braunwart"
date: "2024-01-15"
tags: ["azure", "network", "vnet", "dns", "terraform", "infrastructure"]
summary: "Terraform module for deploying enterprise-grade Azure Service Bus with robust messaging, security, and automation capabilities"
---

<!-- BEGIN_TF_DOCS -->
<!-- TOC -->
- [Azure Service Bus Infrastructure Module](#azure-service-bus-infrastructure-module)
  - [Purpose](#purpose)
    - [Key Capabilities](#key-capabilities)
  - [Implementation Details](#implementation-details)
    - [Core Features](#core-features)
    - [Best Practices](#best-practices)
  - [Usage Example](#usage-example)
  - [Diagnostic Settings](#diagnostic-settings)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Resources](#resources)
  - [Required Inputs](#required-inputs)
    - [ location](#-location)
    - [ resource\_group\_name](#-resource_group_name)
    - [ servicebus\_namespace](#-servicebus_namespace)
  - [Optional Inputs](#optional-inputs)
    - [ log\_analytics\_workspace\_id](#-log_analytics_workspace_id)
    - [ servicebus\_queues](#-servicebus_queues)
    - [ servicebus\_topics](#-servicebus_topics)
    - [ storage\_configuration](#-storage_configuration)
    - [ tags](#-tags)
  - [Outputs](#outputs)
    - [ automation\_account](#-automation_account)
    - [ dead\_letter\_queue](#-dead_letter_queue)
    - [ diagnostic\_setting\_id](#-diagnostic_setting_id)
    - [ diagnostic\_setting\_name](#-diagnostic_setting_name)
    - [ managed\_identity](#-managed_identity)
    - [ namespace\_endpoint](#-namespace_endpoint)
    - [ namespace\_id](#-namespace_id)
    - [ namespace\_name](#-namespace_name)
    - [ primary\_connection\_string](#-primary_connection_string)
    - [ primary\_key](#-primary_key)
    - [ queue\_ids](#-queue_ids)
    - [ queue\_names](#-queue_names)
    - [ secondary\_connection\_string](#-secondary_connection_string)
    - [ secondary\_key](#-secondary_key)
    - [ storage\_containers](#-storage_containers)
    - [ topic\_ids](#-topic_ids)
    - [ topic\_names](#-topic_names)
<!-- /TOC -->

# Azure Service Bus Infrastructure Module

## Purpose

This Terraform module deploys an Azure Service Bus namespace with enterprise-grade messaging, auto-forwarding, and automation workflows for streamlined operations and maintenance. It supports queues, topics, and dead-letter handling, along with secure identity management and monitoring features.

### Key Capabilities

- **Premium Service Bus Namespace** with configurable capacity and messaging partitions
- **Comprehensive Queue Management** with configurable message size, TTL, and delivery settings
- **Topic and Subscription Support** for pub/sub messaging patterns
- **Advanced Security Features**
  - Private network access only (public network access disabled)
  - Granular authorization rules (send, listen, manage)
  - SystemAssigned managed identity integration
- **Storage Integration**
  - Dead-letter message archival
  - Session state management
  - Automated container lifecycle management
- **Dead Letter Handling**
  - Dedicated dead-letter queue
  - Automatic message forwarding
  - Configurable retention policies
  - Automated cleanup via Storage lifecycle management
- **Auto-Forwarding** between queues for seamless message routing
- **Azure Automation Integration** for message cleanup and archival
- **Secure Role Assignments** that leverage managed identities for granular access

## Implementation Details

### Core Features

1. **Namespace Configuration**
   - Premium SKU with configurable capacity
   - Private network access enforcement
   - Flexible authorization rules

2. **Message Handling**
   - Configurable message sizes and TTL
   - Session support for ordered message processing
   - Maximum delivery count controls

3. **Storage Integration**
   - Three-container system (service bus, dead letter, session state)
   - Automated blob lifecycle management
   - RBAC-based access control

4. **Monitoring and Diagnostics**
   - Azure Monitor integration
   - Comprehensive logging of all operations
   - Metric collection for performance tracking

### Best Practices

- Implements separate authorization rules for send, listen, and manage operations
- Uses managed identities for secure storage access
- Enforces private network access for enhanced security
- Implements automatic dead-letter message handling
- Provides configurable message retention policies

## Usage Example

```hcl
module "service_bus" {
  source = "github.com/your-org/terraform-azurerm-service-bus"

  resource_group_name = "rg-messaging-prod"
  location            = "westeurope"

  servicebus_namespace = {
    name                          = "sb-messaging-prod"
    sku                          = "Premium"
    capacity                     = 2
    premium_messaging_partitions = 1
    auth_rules = {
      manage = true
      send   = false
      listen = false
    }
  }

  storage_configuration = {
    enabled = true
    storage_account_id = "/subscriptions/.../resourceGroups/storage-rg/providers/Microsoft.Storage/storageAccounts/mystorageaccount"
    containers = {
      service_bus = {
        name        = "service-bus"
        access_type = "private"
      }
      dead_letter = {
        name      = "dead-letter"
        ttl_days  = 30
        access_type = "private"
      }
      session_state = {
        name        = "session-state"
        access_type = "private"
      }
    }
  }
}
```

## Diagnostic Settings

The module automatically configures diagnostic settings to capture all logs and metrics in the specified Log Analytics workspace, enabling comprehensive monitoring and troubleshooting capabilities.

## Requirements

The following requirements are needed by this module:

- <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) (~> 4.12.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) (~> 4.12.0)

## Resources

The following resources are used by this module:

- [azurerm_automation_account.message_transfer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_account) (resource)
- [azurerm_monitor_diagnostic_setting.sb_diag](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_role_assignment.automation_servicebus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.automation_storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.container_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_servicebus_namespace.sb_ns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace) (resource)
- [azurerm_servicebus_namespace_authorization_rule.listen_only](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace_authorization_rule) (resource)
- [azurerm_servicebus_namespace_authorization_rule.manage_only](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace_authorization_rule) (resource)
- [azurerm_servicebus_namespace_authorization_rule.send_only](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace_authorization_rule) (resource)
- [azurerm_servicebus_queue.dead_letter_queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue) (resource)
- [azurerm_servicebus_queue.sb_queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue) (resource)
- [azurerm_servicebus_queue_authorization_rule.listen_only](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue_authorization_rule) (resource)
- [azurerm_servicebus_queue_authorization_rule.manage_only](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue_authorization_rule) (resource)
- [azurerm_servicebus_queue_authorization_rule.send_only](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue_authorization_rule) (resource)
- [azurerm_servicebus_subscription.sb_sub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_subscription) (resource)
- [azurerm_servicebus_topic.sb_topic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic) (resource)
- [azurerm_servicebus_topic_authorization_rule.listen_only](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic_authorization_rule) (resource)
- [azurerm_servicebus_topic_authorization_rule.manage_only](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic_authorization_rule) (resource)
- [azurerm_servicebus_topic_authorization_rule.send_only](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic_authorization_rule) (resource)
- [azurerm_storage_container.c](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) (resource)
- [azurerm_storage_management_policy.deadletter_lifecycle](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input_location)

Description: The location/region where the key vault should be created.

Type: `string`

### <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name)

Description: The name of the resource group in which the key vault should be created.

Type: `string`

### <a name="input_servicebus_namespace"></a> [servicebus_namespace](#input_servicebus_namespace)

Description: The Service Bus namespace configuration.

Type:

```hcl
object({
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
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_log_analytics_workspace_id"></a> [log_analytics_workspace_id](#input_log_analytics_workspace_id)

Description: The ID of the Log Analytics workspace

Type: `string`

Default: `""`

### <a name="input_servicebus_queues"></a> [servicebus_queues](#input_servicebus_queues)

Description: The name of the Service Bus queue.

Type:

```hcl
list(object({
    name                          = string
    max_message_size_in_kilobytes = optional(number, 1024)
    max_delivery_count            = optional(number, 30)
    auth_rules = optional(object({
      send   = optional(bool, false)
      listen = optional(bool, false)
      manage = optional(bool, false)
    }))
  }))
```

Default: `[]`

### <a name="input_servicebus_topics"></a> [servicebus_topics](#input_servicebus_topics)

Description: The name of the Service Bus topic.

Type:

```hcl
list(object({
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
```

Default: `[]`

### <a name="input_storage_configuration"></a> [storage_configuration](#input_storage_configuration)

Description: Storage account configuration for Service Bus features

Type:

```hcl
object({
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
```

Default:

```json
{
  "containers": null,
  "enabled": false,
  "storage_account_id": null
}
```

### <a name="input_tags"></a> [tags](#input_tags)

Description: A mapping of tags to assign to the resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_automation_account"></a> [automation_account](#output_automation_account)

Description: Automation account for message transfer

### <a name="output_dead_letter_queue"></a> [dead_letter_queue](#output_dead_letter_queue)

Description: Dead letter queue details

### <a name="output_diagnostic_setting_id"></a> [diagnostic_setting_id](#output_diagnostic_setting_id)

Description: The ID of the diagnostic setting

### <a name="output_diagnostic_setting_name"></a> [diagnostic_setting_name](#output_diagnostic_setting_name)

Description: The name of the diagnostic setting

### <a name="output_managed_identity"></a> [managed_identity](#output_managed_identity)

Description: The managed identity of the Service Bus namespace

### <a name="output_namespace_endpoint"></a> [namespace_endpoint](#output_namespace_endpoint)

Description: The Service Bus Namespace endpoint

### <a name="output_namespace_id"></a> [namespace_id](#output_namespace_id)

Description: The Service Bus Namespace ID

### <a name="output_namespace_name"></a> [namespace_name](#output_namespace_name)

Description: The Service Bus Namespace name

### <a name="output_primary_connection_string"></a> [primary_connection_string](#output_primary_connection_string)

Description: The primary connection string for the Service Bus namespace

### <a name="output_primary_key"></a> [primary_key](#output_primary_key)

Description: The primary key for the Service Bus namespace

### <a name="output_queue_ids"></a> [queue_ids](#output_queue_ids)

Description: Map of queue names to their IDs

### <a name="output_queue_names"></a> [queue_names](#output_queue_names)

Description: List of created queue names

### <a name="output_secondary_connection_string"></a> [secondary_connection_string](#output_secondary_connection_string)

Description: The secondary connection string for the Service Bus namespace

### <a name="output_secondary_key"></a> [secondary_key](#output_secondary_key)

Description: The secondary key for the Service Bus namespace

### <a name="output_storage_containers"></a> [storage_containers](#output_storage_containers)

Description: Map of storage container names to their properties

### <a name="output_topic_ids"></a> [topic_ids](#output_topic_ids)

Description: Map of topic names to their IDs

### <a name="output_topic_names"></a> [topic_names](#output_topic_names)

Description: List of created topic names
<!-- END_TF_DOCS -->