locals {
  bucket_url = "${var.bucket_name}.s3.${var.region}.amazonaws.com"
}

resource "aws_cloudfront_distribution" "distribution" {

  comment         = var.bucket_description
  is_ipv6_enabled = true
  enabled         = true

  origin {
    origin_id                 = local.bucket_url
    domain_name               = local.bucket_url
    origin_path               = ""
    origin_access_control_id  = aws_cloudfront_origin_access_control.s3_oac.id
  }

  default_root_object = "/index.html"

  default_cache_behavior {

    target_origin_id = "${var.bucket_name}.s3.${var.region}.amazonaws.com"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = true

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.redirect_handler.arn
    }

    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_100"

}

resource "aws_cloudfront_origin_access_control" "s3_oac" {
  origin_access_control_origin_type = "s3"
  name                              = local.bucket_url
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
  description                       = "OAC for ${var.bucket_name}"
}

resource "aws_cloudfront_function" "redirect_handler" {
  name    = "redirect_handler_${terraform.env}"
  runtime = "cloudfront-js-2.0"
  comment = "Handler function for redirecting to index.html"
  publish = true
  code    = file("${path.module}/redirect_handler.js")
}