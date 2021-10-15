variable "tagNames" {

}

variable "alb_domain_name" {

}


variable "acm_certificate_arn" {

}

variable "domain" {

}

variable "web_acl_id" {

}
resource "aws_cloudfront_distribution" "this" {
  aliases             = [var.domain]
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  tags                = var.tagNames
  tags_all            = var.tagNames
  wait_for_deployment = true
  web_acl_id          = var.web_acl_id
  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress                 = true
    default_ttl              = 0
    max_ttl                  = 0
    min_ttl                  = 0
    origin_request_policy_id = "5e015dea-0a15-490f-88a1-af94b286a673"
    smooth_streaming         = false
    target_origin_id         = var.alb_domain_name
    viewer_protocol_policy   = "https-only"
  }

  origin {
    connection_attempts = 3
    connection_timeout  = 10
    domain_name         = var.alb_domain_name
    origin_id           = var.alb_domain_name

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }
  restrictions {
    geo_restriction {
      locations        = ["JP"]
      restriction_type = "whitelist"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}
