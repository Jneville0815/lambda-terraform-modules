resource "null_resource" "packaging" {
  triggers = {
    dependencies = join(" ", var.pip_dependencies)
    script_sha1  = sha1(file("${path.module}/../lambdas/${var.function_name}/${var.function_name}.py"))
  }

  # clean the folder
  provisioner "local-exec" {
    command = "rm -rf /tmp/${var.temp_package_folder}"
  }

  # recreate the folder
  provisioner "local-exec" {
    command = "mkdir /tmp/${var.temp_package_folder}"
  }

  # install dependencies to the folder
  provisioner "local-exec" {
    command = "pip3 install ${join(" ", var.pip_dependencies)} --target /tmp/${var.temp_package_folder}"
  }

  # copy your script to the folder
  provisioner "local-exec" {
    command = "cp ${path.module}/../lambdas/${var.function_name}/${var.function_name}.py /tmp/${var.temp_package_folder}/"
  }
}

data "null_data_source" "packaging_changes" {
  inputs = {
    null_id      = null_resource.packaging.id
    package_path = "${path.module}/../lambdas/${var.function_name}/${var.function_name}.zip"
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "/tmp/${var.temp_package_folder}"
  output_path = data.null_data_source.packaging_changes.outputs["package_path"]
}

resource "aws_lambda_function" "lambda" {
  function_name                  = var.function_name
  description                    = var.function_description
  role                           = aws_iam_role.lambda_iam_role.arn
  filename                       = data.archive_file.lambda.output_path
  handler                        = "${var.function_name}.lambda_handler"
  source_code_hash               = data.archive_file.lambda.output_base64sha256
  runtime                        = "python3.9"
  reserved_concurrent_executions = 1
  memory_size                    = 128
  timeout                        = 900

  environment {
    variables = var.lambda_env_vars
  }

  tags = var.global.tags
}

resource "aws_lambda_permission" "invoke_permission_from_cloudwatch_events" {
  count         = var.function_cron_schedule != null ? 1 : 0
  statement_id  = "${var.function_name}_lambda_permission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_cron_schedule_rule[0].arn
}