variable "function_name" {
  type = string
}

variable "function_description" {
  type = string
}

variable "function_cron_schedule" {
  type = string
}

variable "iam_policy_vars" {
  type    = map(string)
  default = {}
}

variable "lambda_env_vars" {
  type    = map(string)
  default = {}
}

variable "pip_dependencies" {
  default = []
}

variable "temp_package_folder" {
  default = "python_lambda_package"
}

variable "script_directory" {
  type = string
}

variable "global" {
  type = object({
    repository_name = string
    aws_account_id  = string
    aws_region      = string
    tags            = map(string)
  })
}
