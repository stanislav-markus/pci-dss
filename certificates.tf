locals {
  domain_labels      = split(".", trimsuffix(var.domain_name, "."))
  inferred_zone_name = length(local.domain_labels) > 2 ? join(".", slice(local.domain_labels, 1, length(local.domain_labels))) : var.domain_name
  hosted_zone_name   = var.hosted_zone_name != "" ? var.hosted_zone_name : local.inferred_zone_name
}

data "aws_route53_zone" "app" {
  name         = "${trimsuffix(local.hosted_zone_name, ".")}."
  private_zone = false
}

resource "aws_acm_certificate" "alb" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.tags, {
    Name = "${local.name}-alb"
  })
}

resource "aws_route53_record" "certificate_validation" {
  for_each = {
    for option in aws_acm_certificate.alb.domain_validation_options : option.domain_name => {
      name   = option.resource_record_name
      record = option.resource_record_value
      type   = option.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.app.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "alb" {
  certificate_arn         = aws_acm_certificate.alb.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.app.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}
