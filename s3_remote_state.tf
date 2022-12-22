resource "aws_s3_bucket" "remote_state" {
  bucket = "tfstate-${local.global.repository_name}"
  tags   = local.global.tags
}

resource "aws_s3_bucket_acl" "remote_state" {
  bucket = aws_s3_bucket.remote_state.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "remote_state" {
  bucket = aws_s3_bucket.remote_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "remote_state" {
  bucket = aws_s3_bucket.remote_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}