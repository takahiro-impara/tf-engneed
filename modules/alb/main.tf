variable "tagNames" {

}

variable "securitygroups" {

}

variable "subnets" {

}



variable "vpc_id" {

}

variable "domain" {

}
variable "aws_acm_certificate" {

}

variable "aws_cloudfront_distribution" {

}
resource "aws_lb" "this" {
  name               = var.tagNames["Name"]
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.securitygroups
  subnets            = var.subnets
  tags               = var.tagNames
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"
  /*
  certificate_arn   = var.aws_acm_certificate.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  */
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not authorized"
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "forward" {
  listener_arn = aws_lb_listener.this.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_http.arn
  }

  condition {
    http_header {
      http_header_name = "User-agent"
      values           = ["Amazon CloudFront"]
    }
  }
}

resource "aws_lb_target_group" "ec2_http" {
  name     = "inomaso-dev-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    interval            = 10
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
data "aws_route53_zone" "this" {
  name         = var.domain
  private_zone = false
}

resource "aws_route53_record" "this" {
  for_each = {
    for dvo in var.aws_acm_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this.id
}

resource "aws_route53_record" "main" {
  type = "A"

  name    = var.domain
  zone_id = data.aws_route53_zone.this.id

  alias {
    name                   = var.aws_cloudfront_distribution.domain_name
    zone_id                = var.aws_cloudfront_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}


