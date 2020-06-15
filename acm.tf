resource "aws_acm_certificate" "s3_site" {
  provider = "aws.east"
  domain_name = "${local.full_domain}"
  validation_method = "DNS"
  tags = "${merge(map(var.base_tags, local.s3_site_tags))}"
}

resource "aws_acm_certificate_validation" "s3_site" {
  provider = "aws.east"
  certificate_arn = "${aws_acm_certificate.s3_site.arn}"
  validation_record_fqdns = ["${aws_route53_record.acm_verify.fqdn}"]
}
