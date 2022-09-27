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
      name = each.key

      hash_key  = each.value.hash_key.name
      range_key = try(each.value.range_key.name, null)

      projection_type    = each.value.projection_type
      non_key_attributes = each.value.non_key_attributes

      read_capacity  = var.provisioned_capacity.enabled ? coalesce(try(each.value.provisioned_capacity.read, null), var.provisioned_capacity.read) : null
      write_capacity = var.provisioned_capacity.enabled ? coalesce(try(each.value.provisioned_capacity.write, null), var.provisioned_capacity.write) : null
    }
  }

  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes
    content {
      name               = each.key
      range_key          = each.value.range_key.name
      non_key_attributes = each.value.non_key_attributes
      projection_type    = each.value.projection_type
    }
  }

  # Defines all attribute types for the primary index, global secondary indexes, and local secondary indexes
  dynamic "attribute" {
    for_each = local.attributes
    content {
      name = each.key
      type = each.value
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
    for_each = var.replica_settings.externally_managed ? {} : var.replica_settings.regions
    content {
      region_name            = each.key
      kms_key_arn            = each.value.kms_key_arn
      point_in_time_recovery = each.value.point_in_time_recovery
      propagate_tags         = each.value.propagate_tags
    }
  }

  stream_enabled   = var.stream_settings.enabled && var.stream_settings.kinesis == null ? true : false
  stream_view_type = var.stream_settings.enabled && var.stream_settings.kinesis == null ? var.stream_settings.view_type : null

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_dynamodb_kinesis_streaming_destination" "this" {
  count      = var.stream_settings.enabled && var.stream_settings.kinesis != null ? 1 : 0
  table_name = aws_dynamodb_table.this.name
  stream_arn = var.stream_settings.kinesis.arn
}
