data "aws_iam_policy_document" "s3_site_bucket_policy" {
  statement {
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_site.arn}/*"]
    principals {
      type = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }
  statement {
    actions = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.s3_site.arn}"]
    principals {
      type = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket" "s3_site_logs" {
  bucket = "${local.full_domain}-logs"
  acl = "log-delivery-write"
  lifecycle_rule {
    id = "log"
    enabled = true
    expiration {
      days = 90
    }
  }
  tags = "${merge(map("Creator", var.creator), map("Environment", var.full_env), var.base_tags, local.s3_site_tags)}"
}

resource "aws_s3_bucket" "s3_site" {
  bucket = "${local.full_domain}"
  acl = "private"
  website {
    index_document = "index.html"
    error_document = "index.html"
  }
  versioning {
    enabled = true
  }
  logging {
    target_bucket = "${aws_s3_bucket.s3_site_logs.id}"
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag", "Content-Length", "Content-Type"]
    max_age_seconds = 3000
  }

  tags = "${merge(map("Creator", var.creator), map("Environment", var.full_env), var.base_tags, local.s3_site_tags)}"
}



resource "aws_s3_bucket_policy" "s3_site" {
  bucket = "${aws_s3_bucket.s3_site.id}"
  policy = "${data.aws_iam_policy_document.s3_site_bucket_policy.json}"
}

