table_class   = "STANDARD_INFREQUENT_ACCESS"
hash_key      = { name = "pk" }
range_key     = { name = "sk" }
ttl_attribute = { name = "ttl" }

kms_key_arn = "some-kms-arn"
provisioned_capacity = {
  enabled = true
  read    = 5
  write   = 1
}
global_secondary_indexes = {
  "sk-pk-index" = {
    hash_key  = { name = "sk" }
    range_key = { name = "pk" }
  }
}
point_in_time_recovery_enabled = false
replica_settings = {
  "eu-central-1" = {}
  "us-east-1"    = {}
}
stream_settings = {
  enabled = true
}
