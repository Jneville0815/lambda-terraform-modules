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

data "aws_ssm_parameter" "quote_backend_endpoint" {
  name = "QUOTE_BACKEND_ENDPOINT"
}

data "aws_ssm_parameter" "recipient_phone_number" {
  name = "RECIPIENT_PHONE_NUMBER"
}

# Second recipient for the optional reminder. Both are read as regular
# parameters, so create them with an empty value to disable the reminder
# rather than deleting them — a missing parameter fails the plan.
data "aws_ssm_parameter" "reminder_phone_number" {
  name = "REMINDER_PHONE_NUMBER"
}

data "aws_ssm_parameter" "reminder_message" {
  name = "REMINDER_MESSAGE"
}
