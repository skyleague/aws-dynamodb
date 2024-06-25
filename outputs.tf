output "table" {
  value = aws_dynamodb_table.this
}

output "policies" {
  value = var.output_policies ? {
    read   = data.aws_iam_policy_document.read[0],
    scan   = data.aws_iam_policy_document.scan[0],
    write  = data.aws_iam_policy_document.write[0],
    delete = data.aws_iam_policy_document.delete[0],
  } : null
}
