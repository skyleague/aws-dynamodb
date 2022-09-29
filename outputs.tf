output "table" {
  value = aws_dynamodb_table.this
}

output "policies" {
  value = {
    read   = data.aws_iam_policy_document.read,
    scan   = data.aws_iam_policy_document.scan,
    write  = data.aws_iam_policy_document.write,
    delete = data.aws_iam_policy_document.delete,
  }
}
