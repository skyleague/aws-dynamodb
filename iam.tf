data "aws_iam_policy_document" "read" {
  statement {
    effect = "Allow"
    resources = [
      aws_dynamodb_table.this.arn,
      "${aws_dynamodb_table.this.arn}/index/*",
    ]
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:ConditionCheckItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
    ]
  }
}

data "aws_iam_policy_document" "scan" {
  statement {
    effect = "Allow"
    resources = [
      aws_dynamodb_table.this.arn,
      "${aws_dynamodb_table.this.arn}/index/*",
    ]
    actions = [
      "dynamodb:Scan",
    ]
  }
}

data "aws_iam_policy_document" "write" {
  statement {
    effect    = "Allow"
    resources = [aws_dynamodb_table.this.arn]
    actions = [
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
    ]
  }
}

data "aws_iam_policy_document" "delete" {
  statement {
    effect    = "Allow"
    resources = [aws_dynamodb_table.this.arn]
    actions = [
      "dynamodb:DeleteItem",
    ]
  }
}
