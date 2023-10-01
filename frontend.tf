##################
### FrontEnd
##################

## S3 Bucket
resource "aws_s3_bucket" "frontend" {
  bucket = var.frontend_bucket_name
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  policy = <<EOF
    {
      "Version" : "2008-10-17",
      "Id" : "PolicyForCloudFrontPrivateContent",
      "Statement" : [
        {
          "Sid" : "AllowCloudFrontServicePrincipal",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "cloudfront.amazonaws.com"
          },
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::${var.frontend_bucket_name}/*",
          "Condition" : {
            "StringEquals" : {
              "AWS:SourceArn" : "arn:aws:cloudfront::${local.account_id}:distribution/${aws_cloudfront_distribution.frontend.id}"
            }
          }
        }
      ]
    }
EOF
}

## ACM
resource "aws_acm_certificate" "frontend" {
  provider = aws.virginia

  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

## CloudFront
resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  comment             = "CloudFront distribution to deliver a static website using S3 as origin"
  price_class         = "PriceClass_100"
  default_root_object = var.website_entry_document
  aliases             = [local.frontend_fqdn]

  origin {
    origin_id                = "frontend"
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id

  }

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    target_origin_id       = "frontend"
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" // Managed-CachingOptimized
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.frontend.arn
    cloudfront_default_certificate = false
    ssl_support_method             = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "frontend"
  description                       = "Frontend OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

## Route53
resource "aws_route53_record" "front" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.frontend_fqdn
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
    evaluate_target_health = false
  }
}
