resource "aws_route53_zone" "s3_zone" {
  name = "${local.full_domain}"
}

output "r53_zone_nameservers" {
  value = "${aws_route53_zone.s3_zone.name_servers}"
}

resource "aws_route_53_record" "acm_verify" {
  zone_id = "${aws_route53_zone.s3_zone.id}"
  name = "${aws_acm_certificate.s3_site.domain_validation_options.0.resource_record_name}"
  type = "${aws_acm_certificate.s3_site.domain_validation_options.0.resource_record_type}"
  ttl = "300"
  records = ["${aws_acm_certificate.s3_site.domain_validation_options.0.resource_record_value}"]
}

resource "aws_route_53_record" "s3_site" {
  name = "${local.full_domain}"
  type = "A"
  zone_id = "${aws_route53_zone.s3_zone.id}"
  alias {
    evaluate_target_health = false
	name = "${aws_cloudfront_distribution.s3_site.domain_name}"
	zone_id = "${aws_cloudfront_distribution.s3_site.hosted_zone_id}"
}

