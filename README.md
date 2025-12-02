# GitLab on AWS - Terraform

Terraform infrastructure code to deploy a self-hosted GitLab Community Edition (CE) instance on AWS using the official GitLab Omnibus AMI.

## Overview

This project provides a simple, cost-effective way to run your own GitLab instance on AWS for testing, development, or small team use. It deploys:

- **GitLab Community Edition (CE)** - Free, open-source version with all core features
- **GitLab Omnibus** - All-in-one package with GitLab, PostgreSQL, Redis, and Gitaly bundled
- **Single EC2 instance** - Simple architecture, no complex clustering
- **Automatic SSL** - Let's Encrypt certificate configured during setup
- **Secure access** - AWS Systems Manager Session Manager (no SSH keys needed)

Perfect for:
- Testing GitLab features and integrations
- Small development teams (< 100 users)
- CI/CD pipeline development
- Learning GitLab administration

## What Gets Deployed

This Terraform configuration creates:

1. **Networking**
   - VPC with public subnet in a single availability zone
   - Internet Gateway for public internet access
   - Route table with appropriate routing

2. **Compute**
   - EC2 instance (t3.large) running GitLab CE Omnibus
   - 35 GB root volume for GitLab data
   - IAM instance profile for Systems Manager access

3. **DNS**
   - Route53 hosted zone for your domain
   - A record pointing to the GitLab instance

4. **Security**
   - Security group allowing HTTP (80), HTTPS (443), and SSH (22)
   - IAM role with Systems Manager permissions

5. **State Management**
   - S3 bucket for Terraform state
   - DynamoDB table for state locking

**Total AWS Resources**: 12

**Estimated Monthly Cost**: ~$70-80 USD
- EC2 t3.large: ~$60/month
- EBS 35GB: ~$3.50/month
- Route53 hosted zone: $0.50/month
- Data transfer: varies

## Prerequisites

1. **Domain name** for your GitLab instance
   - You can use an existing domain or subdomain
   - Domain must be manageable via Route53 or have the ability to add NS records
   - Examples: `gitlab.example.com` or `git.mycompany.com`

2. AWS credentials configured with appropriate permissions
   - Permissions needed: EC2, VPC, Route53, IAM, S3, DynamoDB, Systems Manager

3. AWS CLI installed

4. Terraform >= 1.0 installed

## Setup

1. **Set AWS profile**:
   ```bash
   export AWS_PROFILE=your-profile-name
   ```

2. **Create terraform.tfvars**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars and set your domain_name
   ```

3. **Initialize Terraform backend**:
   ```bash
   ./init.sh
   ```
   This creates the S3 bucket, DynamoDB table, and generates `backend.tf`

4. **Initialize Terraform**:
   ```bash
   terraform init
   ```

5. **Review the plan**:
   ```bash
   terraform plan
   ```

6. **Apply the configuration**:
   ```bash
   terraform apply
   ```

7. **Configure DNS delegation** (if using subdomain):
   - After apply, note the nameservers from the output
   - Add NS records in parent domain pointing to these nameservers

8. **Connect to the instance** (via AWS Systems Manager):
   ```bash
   # Get the SSM connect command from output
   terraform output ssm_connect_command

   # Run the command
   aws ssm start-session --target <instance-id> --region us-west-2
   ```

9. **Configure GitLab**:
   ```bash
   # Edit GitLab configuration
   sudo vim /etc/gitlab/gitlab.rb

   # Update the external_url line to your domain
   external_url 'https://your-domain.com'

   # Save and exit (:wq)

   # Apply configuration (takes 5-10 minutes)
   sudo gitlab-ctl reconfigure
   ```

10. **Access GitLab**:
    - Visit the GitLab URL from terraform output
    - Login with username `root` and password = instance ID
    - Get instance ID: `terraform output gitlab_instance_id`

11. **Change root password** (recommended):
    - After logging in, click your avatar (top right) → Edit profile
    - Left sidebar → Password
    - Set a strong new password
    - Save changes

9. **Access GitLab**:
   - Visit the GitLab URL from terraform output
   - Login with username `root` and password = instance ID
   - Get instance ID: `terraform output gitlab_instance_id`

## DNS Delegation

After `terraform apply`, you'll get nameservers for the hosted zone:

```bash
# Get nameservers from terraform output
terraform output hosted_zone_nameservers

# Add NS records in parent domain pointing to these nameservers
```

## Architecture

- **VPC**: Single AZ with public subnet
- **EC2**: t3.large instance with GitLab official AMI
- **Storage**: 35 GB root volume
- **DNS**: Route53 hosted zone
- **SSL**: Let's Encrypt (configured post-deployment)
- **Access**: AWS Systems Manager Session Manager (no SSH keys required)

## Teardown

```bash
terraform destroy
```

## Configuration

Create a `terraform.tfvars` file to customize:

```hcl
domain_name      = "gitlab.example.com"
instance_type    = "t3.large"
root_volume_size = 35
```
