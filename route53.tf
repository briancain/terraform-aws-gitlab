# Route53 Hosted Zone
resource "aws_route53_zone" "gitlab" {
  name = var.domain_name

  tags = {
    Name = "${var.project_name}-zone"
  }
}

# A Record pointing to GitLab instance
resource "aws_route53_record" "gitlab" {
  zone_id = aws_route53_zone.gitlab.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 300
  records = [aws_instance.gitlab.public_ip]
}
