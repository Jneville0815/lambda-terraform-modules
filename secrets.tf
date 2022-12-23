data "aws_ssm_parameter" "twilio_auth_token" {
  name = "TWILIO_AUTH_TOKEN"
}

data "aws_ssm_parameter" "twilio_account_sid" {
  name = "TWILIO_ACCOUNT_SID"
}

data "aws_ssm_parameter" "twilio_phone_number" {
  name = "TWILIO_PHONE_NUMBER"
}

data "aws_ssm_parameter" "website_email" {
  name = "WEBSITE_EMAIL"
}

data "aws_ssm_parameter" "website_password" {
  name = "WEBSITE_PASSWORD"
}