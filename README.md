# lambda-terraform-modules

A Terraform module that turns a Python file into a scheduled AWS Lambda.

Point it at a directory containing `<name>.py` and an IAM policy, give it a list
of pip dependencies and a cron expression, and it handles the rest: installing
the dependencies, building the deployment bundle, and creating the function, its
role, its log group, and its schedule. There is no separate build step, no CI
job that zips things, and no build artifact in the repository.

```hcl
module "quote_text" {
  source                 = "./lambda_module"
  function_name          = "quote_text"
  script_directory       = "${path.module}/lambdas/quote_text"
  function_description   = "Sends daily texts from database of quotes"
  function_cron_schedule = "cron(0 12,0 * * ? *)"
  pip_dependencies       = ["twilio==7.16.0"]
  lambda_env_vars = {
    TWILIO_ACCOUNT_SID = data.aws_ssm_parameter.twilio_account_sid.value
  }
  global = local.global
}
```

That's a complete, deployed, scheduled function.

---

## Contents

- [Why packaging in Terraform](#why-packaging-in-terraform)
- [Module reference](#module-reference)
- [What it creates](#what-it-creates)
- [Adding a function](#adding-a-function)
- [The worked example](#the-worked-example)
- [Deploying](#deploying)
- [Notes](#notes)

---

## Why packaging in Terraform

The usual way to ship a Python Lambda is a CI job that pip-installs into a
directory, zips it, uploads it to S3, and then lets Terraform point at the
object. That works, but it splits one deployment across two systems: the
pipeline owns the bundle and Terraform owns the function, and they drift.

This module does the packaging inside the same `terraform apply` that creates
the function. `null_resource` provisioners install the dependencies into a temp
directory and copy the handler in; `archive_file` zips it; `aws_lambda_function`
consumes that zip and uses its `output_base64sha256` as `source_code_hash`, so a
changed handler redeploys and an unchanged one doesn't.

The tradeoff is that `terraform apply` now needs `pip3` on the machine running
it, and that machine's platform has to match Lambda's. That's the cost of not
having a build pipeline to maintain.

---

## Module reference

| Variable | Type | Required | Purpose |
| --- | --- | --- | --- |
| `function_name` | string | yes | Lambda name. Must match the handler filename — the module derives both the source path (`<script_directory>/<function_name>.py`) and the entrypoint (`<function_name>.lambda_handler`) from it. |
| `script_directory` | string | yes | Directory holding `<function_name>.py` and `iam_policy.json`. |
| `function_description` | string | yes | Shown on the function in the console. |
| `function_cron_schedule` | string | yes | CloudWatch schedule expression, e.g. `cron(0 12 * * ? *)`. Pass `null` to create the function without a schedule — the rule, target and invoke permission are all conditional on it. |
| `pip_dependencies` | list | no | Installed into the bundle, e.g. `["twilio==7.16.0"]`. Pin versions; there's no lockfile. |
| `lambda_env_vars` | map(string) | no | Becomes the function's environment. Read secrets from SSM here rather than hardcoding them. |
| `iam_policy_vars` | map(string) | no | Extra variables for the `iam_policy.json` template. `cloudwatch_logs_group_lambda_arn` is always provided. |
| `temp_package_folder` | string | no | Staging directory under `/tmp`. Defaults to `python_lambda_package`. |
| `global` | object | yes | Shared context: `repository_name`, `aws_account_id`, `aws_region`, `tags`. |

---

## What it creates

Per invocation of the module:

| Resource | Notes |
| --- | --- |
| `aws_lambda_function` | python3.9, 128 MB, 900s timeout, `reserved_concurrent_executions = 1` |
| `aws_iam_role` + `aws_iam_policy` | Role built from your `iam_policy.json`, rendered with `templatefile` |
| `aws_cloudwatch_log_group` | `/aws/lambda/<function_name>`, created explicitly so it carries tags and its ARN can be referenced in the policy |
| `aws_cloudwatch_event_rule` + target | Only when `function_cron_schedule` is set |
| `aws_lambda_permission` | Allows the rule to invoke the function |

The concurrency cap of 1 is deliberate: these are scheduled jobs, and one
runaway schedule shouldn't be able to fan out.

---

## Adding a function

Create `lambdas/<name>/`:

```
lambdas/my_job/
├── my_job.py          # must define lambda_handler(event, context)
└── iam_policy.json    # the function's permissions
```

The policy is a `templatefile`, so it can reference `${cloudwatch_logs_group_lambda_arn}`
plus anything passed via `iam_policy_vars`. The minimum is log access:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["logs:PutLogEvents", "logs:CreateLogStream"],
      "Resource": "${cloudwatch_logs_group_lambda_arn}:*"
    }
  ]
}
```

Then add a module block to `lambdas.tf` and apply.

---

## The worked example

`lambdas/quote_text` is the function this repository was built around. Twice a
day it authenticates against a personal API, pulls a quote, and texts it via
Twilio. It's a fair illustration of the shape: a handler with third-party
dependencies, secrets from the environment, a schedule, and about forty lines of
actual logic.

Everything it needs comes from SSM Parameter Store — nothing is hardcoded, and
the module never sees a literal credential:

| Parameter | Purpose |
| --- | --- |
| `TWILIO_ACCOUNT_SID` / `TWILIO_AUTH_TOKEN` / `TWILIO_PHONE_NUMBER` | Twilio API and sending number |
| `WEBSITE_EMAIL` / `WEBSITE_PASSWORD` | Credentials for the quote API |
| `QUOTE_BACKEND_ENDPOINT` | Base URL of that API |
| `RECIPIENT_PHONE_NUMBER` | Where the quote is sent |
| `REMINDER_PHONE_NUMBER` / `REMINDER_MESSAGE` | Optional second recipient who occasionally gets a fixed message |

The reminder is skipped unless both of its parameters are non-empty. Terraform
reads all of them as ordinary parameters, so set them to an empty string to
disable the reminder rather than deleting them — a missing parameter fails the
plan.

---

## Deploying

Requires Terraform 0.14.9+, `pip3`, and AWS credentials.

```bash
# create the SSM parameters listed above, then
terraform init
terraform plan
terraform apply
```

State lives in S3 with a DynamoDB lock table, both declared in this
configuration and wired up in `backend.tf`.

---

## Notes

- **The AWS resources predate the repository's name.** The state bucket, lock
  table and `source-repository` tag all still say `jimmy-lambda-creation`.
  Renaming them would mean migrating state and retagging every resource for no
  functional gain, so they're left alone. `backend.tf` and `locals.tf` are the
  only places that name survives.
- **`null_data_source` is deprecated.** It still works but warns; it's here to
  force the archive step to re-run after packaging. A modern rewrite would use
  `terraform_data` or drop the indirection entirely.
- **Packaging runs on every apply.** `null_resource.packaging` triggers on
  `timestamp()`, so the bundle is always rebuilt. The function only redeploys
  when the resulting hash changes, but applies are never truly no-ops.
- **One region.** `us-east-1` is hardcoded in `main.tf`.
