resource "aws_cloudfront_function" "rewrite_index" {
  name    = "rewrite-index"
  runtime = "cloudfront-js-1.0"
  comment = "Rewrite folder requests to index.html"
  code    = <<EOF
function handler(event) {
  var request = event.request;
  // If the URI does not have a file extension, rewrite to /index.html
  if (!request.uri.match(/\.[^\/]+$/)) {
    if (request.uri.endsWith('/')) {
      request.uri += 'index.html';
    } else {
      // If it doesn't end with '/', add /index.html
      request.uri += '/index.html';
    }
  }
  return request;
}
EOF
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.site_bucket.bucket_regional_domain_name
    origin_id                = "${var.domain}-static-cloudfront"
    origin_access_control_id = aws_cloudfront_origin_access_control.site_oac.id

    s3_origin_config {
      origin_access_identity = "" # Must be empty when using OAC
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = [var.domain]

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = var.forward-query-string

      cookies {
        forward = "none"
      }
    }

    trusted_signers = var.trusted_signers

    min_ttl          = "0"
    default_ttl      = "300"
    max_ttl          = "1200"
    target_origin_id = "${var.domain}-static-cloudfront"

    // This redirects any HTTP request to HTTPS. Security first!
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.rewrite_index.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
