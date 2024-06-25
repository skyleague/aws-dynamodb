locals {
  attributes = merge(
    { for i, def in var.global_secondary_indexes : def.hash_key.name => def.hash_key.type },
    { for i, def in var.global_secondary_indexes : def.range_key.name => def.range_key.type if def.range_key != null },
    { for i, def in var.local_secondary_indexes : def.range_key.name => def.range_key.type if def.range_key != null },
    { for att in [var.hash_key, var.range_key] : att.name => att.type if att != null },
  )
}

resource "aws_dynamodb_table" "this" {
  name = var.name

  # Read/write capacity settings
  billing_mode   = var.provisioned_capacity.enabled ? "PROVISIONED" : "PAY_PER_REQUEST"
  table_class    = var.table_class
  read_capacity  = var.provisioned_capacity.enabled ? var.provisioned_capacity.read : null
  write_capacity = var.provisioned_capacity.enabled ? var.provisioned_capacity.write : null

  hash_key  = var.hash_key.name
  range_key = try(var.range_key.name, null)

  deletion_protection_enabled = var.deletion_protection_enabled

  dynamic "ttl" {
    for_each = var.ttl_attribute != null ? [var.ttl_attribute] : []
    content {
      enabled        = true
      attribute_name = ttl.value
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name = global_secondary_index.key

      hash_key  = global_secondary_index.value.hash_key.name
      range_key = try(global_secondary_index.value.range_key.name, null)

      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.non_key_attributes

      read_capacity  = var.provisioned_capacity.enabled ? coalesce(try(global_secondary_index.value.provisioned_capacity.read, null), var.provisioned_capacity.read) : null
      write_capacity = var.provisioned_capacity.enabled ? coalesce(try(global_secondary_index.value.provisioned_capacity.write, null), var.provisioned_capacity.write) : null
    }
  }

  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes
    content {
      name               = local_secondary_index.key
      range_key          = local_secondary_index.value.range_key.name
      non_key_attributes = local_secondary_index.value.non_key_attributes
      projection_type    = local_secondary_index.value.projection_type
    }
  }

  # Defines all attribute types for the primary index, global secondary indexes, and local secondary indexes
  dynamic "attribute" {
    for_each = local.attributes
    content {
      name = attribute.key
      type = attribute.value
    }
  }

  dynamic "point_in_time_recovery" {
    for_each = var.point_in_time_recovery_enabled ? [true] : []
    content {
      enabled = true
    }
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  dynamic "replica" {
    for_each = var.replica_settings
    content {
      region_name            = replica.key
      kms_key_arn            = replica.value.kms_key_arn
      point_in_time_recovery = replica.value.point_in_time_recovery
      propagate_tags         = replica.value.propagate_tags
    }
  }

  stream_enabled   = var.stream_settings.enabled && var.stream_settings.kinesis == null ? true : false
  stream_view_type = var.stream_settings.enabled && var.stream_settings.kinesis == null ? var.stream_settings.view_type : null

  tags = var.tags
}

resource "aws_dynamodb_kinesis_streaming_destination" "this" {
  count      = var.stream_settings.enabled && var.stream_settings.kinesis != null ? 1 : 0
  table_name = aws_dynamodb_table.this.name
  stream_arn = var.stream_settings.kinesis.arn
}
