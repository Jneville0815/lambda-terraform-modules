resource "aws_cloudwatch_event_rule" "lambda_cron_schedule_rule" {
  count               = var.function_cron_schedule != null ? 1 : 0
  name                = "${var.function_name}_lambda_cron_schedule_rule"
  description         = "${var.function_name} lambda rule running ${var.function_cron_schedule}"
  schedule_expression = var.function_cron_schedule
  tags                = var.global.tags
}

resource "aws_cloudwatch_event_target" "lambda_cron_schedule_target" {
  count     = var.function_cron_schedule != null ? 1 : 0
  arn       = aws_lambda_function.lambda.arn
  rule      = aws_cloudwatch_event_rule.lambda_cron_schedule_rule[0].name
  target_id = "${var.function_name}_lambda_target"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name = "/aws/lambda/${var.function_name}"

  tags = var.global.tags
}