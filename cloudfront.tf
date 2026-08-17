resource "aws_cloudfront_origin_access_control" "website" {
  name                              = "fiscus-website-oac"
  description                       = "S3 access for the Fiscus website distribution"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# S3 REST origins don't resolve directory indexes; rewrite /docs/ -> /docs/index.html
resource "aws_cloudfront_function" "index-rewrite" {
  name    = "fiscus-website-index-rewrite"
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = <<-EOT
    function handler(event) {
      var request = event.request;
      var uri = request.uri;
      if (uri.endsWith('/')) {
        request.uri += 'index.html';
      } else if (!uri.includes('.')) {
        request.uri += '/index.html';
      }
      return request;
    }
  EOT
}

data "aws_cloudfront_cache_policy" "caching-optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Fiscus website (${local.domain})"
  default_root_object = "index.html"
  aliases             = [local.domain]
  price_class         = "PriceClass_100" # NA + EU edges only
  http_version        = "http2and3"

  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = "s3-website"
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-website"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching-optimized.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.index-rewrite.arn
    }
  }

  # With OAC, missing objects surface as 403 from S3 — serve Hugo's 404 page for both
  custom_error_response {
    error_code         = 403
    response_code      = 404
    response_page_path = "/404.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/404.html"
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.website.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge(
    { Name = "fiscus-website" },
    local.tags
  )
}
