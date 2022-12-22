data "aws_iam_policy_document" "lambda_assume_role" {
  policy_id = "${var.function_name}_lambda_assume_role_policy_document_${var.global.aws_region}"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_policy" "lambda_iam_policy_from_json_file" {
  name   = "${var.function_name}_lambda_iam_role_policy_${var.global.aws_region}"
  policy = templatefile("${var.script_directory}/iam_policy.json", merge(var.iam_policy_vars, { cloudwatch_logs_group_lambda_arn = aws_cloudwatch_log_group.lambda.arn }))
}

resource "aws_iam_role" "lambda_iam_role" {
  name               = "${var.function_name}_lambda_role_${var.global.aws_region}"
  description        = "${var.function_name} role for Lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  inline_policy {}
  managed_policy_arns = [aws_iam_policy.lambda_iam_policy_from_json_file.arn]
  tags                = var.global.tags
}
