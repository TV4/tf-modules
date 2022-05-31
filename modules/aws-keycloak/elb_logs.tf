
resource "aws_s3_bucket" "keycloak_lb_access_logs" {
  bucket = var.access_logs_s3_bucket_name
  tags   = local.default_tags
  policy = data.aws_iam_policy_document.keycloak_lb_access_logs.json
}

data "aws_iam_policy_document" "keycloak_lb_access_logs" {
  statement {
    actions = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::${var.access_logs_s3_bucket_name}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "arn:aws:s3:::${var.access_logs_s3_bucket_name}"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_elb_service_account.main.id}:root"]
    }
  }
  statement {
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.access_logs_s3_bucket_name}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
  statement {
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${var.access_logs_s3_bucket_name}"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
}

resource "aws_s3_bucket_acl" "keycloak_lb_access_logs" {
  bucket = aws_s3_bucket.keycloak_lb_access_logs.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "keycloak_lb_access_logs" {
  bucket = aws_s3_bucket.keycloak_lb_access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "keycloak_lb_access_logs" {
  bucket = aws_s3_bucket.keycloak_lb_access_logs.bucket
  rule {
    id = "keycloak_lb_access_logs"
    expiration {
      days = 365
    }
    status = "Enabled"
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_versioning" "keycloak_lb_access_logs" {
  bucket = aws_s3_bucket.keycloak_lb_access_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}
