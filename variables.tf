variable "name" {
  description = "Name of the DynamoDB Table"
  type        = string
}

variable "hash_key" {
  description = "Hash key configuration."
  type = object({
    name = string
    type = optional(string, "S")
  })
}

variable "range_key" {
  description = "Range key configuration"
  type = object({
    name = string
    type = optional(string, "S")
  })
  default = null
}

variable "ttl_attribute" {
  description = "Name of the TTL field for items (must be in seconds)"
  type        = string
  default     = null
}

variable "provisioned_capacity" {
  description = "Enables and configures provisioned capacity"
  type = object({
    enabled = bool
    read    = optional(number, 5)
    write   = optional(number, 5)
  })
  default = { enabled = false }
}

variable "global_secondary_indexes" {
  description = "Global secondary index configurations"
  type = map(object({
    hash_key = object({
      name = string
      type = optional(string, "S")
    })
    range_key = optional(object({
      name = string
      type = optional(string, "S")
    }))
    projection_type    = optional(string, "KEYS_ONLY")
    non_key_attributes = optional(set(string))
    provisioned_capacity = optional(object({
      read  = number
      write = number
    }))
  }))
  default = {}
}

variable "local_secondary_indexes" {
  description = "Local secondary index configurations (NOTE: this cannot be configured after the table is already created, only by recreating the table)"
  type = map(object({
    range_key = object({
      name = string
      type = optional(string, "S")
    })
    projection_type    = optional(string, "KEYS_ONLY")
    non_key_attributes = optional(set(string))
  }))
  default = {}
}

variable "deletion_protection_enabled" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery (recommended)"
  type        = bool
  default     = true
}

variable "table_class" {
  description = "Storage class for the table"
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "Configure a custom KMS key for encryption (defaults to alias/aws/dynamodb)"
  type        = string
  default     = null
}

variable "stream_settings" {
  description = "Settings for attaching a stream to the table"
  type = object({
    enabled   = bool
    view_type = optional(string, "NEW_AND_OLD_IMAGES")
    kinesis   = optional(object({ arn = string }))
  })
  default = { enabled = false }
}

variable "replica_settings" {
  description = "Settings for DynamoDB Global Tables"
  type = map(object({
    kms_key_arn            = optional(string)
    point_in_time_recovery = optional(bool)
    propagate_tags         = optional(bool, true)
  }))
  default = {}
}

variable "tags" {
  description = "Resource tags for the table"
  type        = map(string)
  default     = null
}

variable "output_policies" {
  description = "Generate default set of policies for the table"
  type        = bool
  default     = false
}
