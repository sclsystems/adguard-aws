resource "aws_acm_certificate" "adguard_certificate" {
  domain_name               = var.domain_name
  subject_alternative_names = var.alternative_domain_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
