variable "region" {
}

variable "hosted_zone_id" {
}

variable "domain" {
}

variable "bucket_name" {
}

variable "certarn" {
}

provider "aws" {
  region = "${var.region}"
}

resource "aws_s3_bucket" "website" {
  bucket = "${var.bucket_name}"
  acl = "public-read"
  policy = <<POLICY
{
  "Id": "Policy1505512068029",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1505512065521",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.bucket_name}/*",
      "Principal": "*"
    }
  ]
}
POLICY

website {
  index_document = "index.html"
  error_document = "404.html"
  }

}

resource "aws_route53_record" "blog_record" {
  zone_id = "${var.hosted_zone_id}"
  type = "A"
  name = "${var.domain}"
  alias {
    name = "${aws_cloudfront_distribution.frontend.domain_name}"
    zone_id = "${aws_cloudfront_distribution.frontend.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_cloudfront_distribution" "frontend" {
  origin {
    domain_name = "${var.bucket_name}.s3.amazonaws.com"
    origin_id = "S3origin"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = ["${var.domain}"]
  enabled = true
  default_root_object = "index.html"
  price_class = "PriceClass_100"
  retain_on_delete = true
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = "S3origin"
    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400

  }
  viewer_certificate {
    acm_certificate_arn = "${var.certarn}"
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}