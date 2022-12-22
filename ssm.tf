data "aws_ssm_parameter" "twilio_auth_token" {
  name = "TWILIO_AUTH_TOKEN"
}

data "aws_ssm_parameter" "twilio_account_sid" {
  name = "TWILIO_ACCOUNT_SID"
}

data "aws_ssm_parameter" "twilio_phone_number" {
  name = "TWILIO_PHONE_NUMBER"
}