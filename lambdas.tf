module "quote_text" {
  source                 = "./lambda_module"
  function_name          = "quote_text"
  script_directory       = "${path.module}/lambdas/quote_text"
  function_description   = "Sends daily texts from database of quotes"
  function_cron_schedule = "rate(1 day)"
  pip_dependencies       = ["twilio==7.16.0"]
  lambda_env_vars = {
    TWILIO_AUTH_TOKEN   = data.aws_ssm_parameter.twilio_auth_token.value
    TWILIO_ACCOUNT_SID  = data.aws_ssm_parameter.twilio_account_sid.value
    TWILIO_PHONE_NUMBER = data.aws_ssm_parameter.twilio_phone_number.value
    EMAIL               = data.aws_ssm_parameter.website_email.value
    PASSWORD            = data.aws_ssm_parameter.website_password.value
  }
  global = local.global
}
