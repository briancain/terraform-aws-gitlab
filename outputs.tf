output "gitlab_instance_id" {
  description = "GitLab EC2 instance ID"
  value       = aws_instance.gitlab.id
}

output "gitlab_public_ip" {
  description = "GitLab EC2 instance public IP"
  value       = aws_instance.gitlab.public_ip
}

output "gitlab_url" {
  description = "GitLab URL"
  value       = "https://${var.domain_name}"
}

output "hosted_zone_id" {
  description = "Route53 hosted zone ID"
  value       = aws_route53_zone.gitlab.zone_id
}

output "hosted_zone_nameservers" {
  description = "Route53 hosted zone nameservers (add these as NS records in parent domain)"
  value       = aws_route53_zone.gitlab.name_servers
}

output "ssm_connect_command" {
  description = "Command to connect to instance via AWS Systems Manager"
  value       = "aws ssm start-session --target ${aws_instance.gitlab.id}"
}
