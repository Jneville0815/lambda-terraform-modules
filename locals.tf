locals {
  global = {
    repository_name = "jimmy-lambda-creation"
    aws_account_id  = data.aws_caller_identity.current.account_id
    aws_region      = data.aws_region.current.name
    tags = {
      "source-repository" = "jimmy-lambda-creation"
      "owner-email"       = "jimmyeneville@gmail.com"
    }
  }
}