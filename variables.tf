variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "gitlab"
}

variable "domain_name" {
  description = "Domain name for GitLab"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file (leave empty to skip key pair creation)"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type for GitLab"
  type        = string
  default     = "t3.large"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 35
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}
