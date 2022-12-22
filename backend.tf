terraform {
  backend "s3" {
    bucket         = "tfstate-jimmy-lambda-creation"
    key            = "tfstate-jimmy-lambda-creation/tfstate/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-lock-jimmy-lambda-creation"
  }
}