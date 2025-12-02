# GitLab on AWS - Terraform

Simple GitLab Community Edition deployment on AWS for testing and API integration.

## Prerequisites

1. AWS credentials configured with appropriate permissions
2. AWS CLI installed
3. Terraform >= 1.0 installed

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

8. **Wait for GitLab to be ready** (~10-15 minutes):
   - GitLab automatically configures itself on first boot
   - SSL certificate is automatically obtained from Let's Encrypt
   - You can check if configuration is complete:
     ```bash
     # Connect to instance
     terraform output ssm_connect_command

     # Check if configuration is complete
     ls -la /var/log/gitlab-configured
     ```

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
- **SSL**: Let's Encrypt (automatically configured via user data)
- **Access**: AWS Systems Manager Session Manager (no SSH keys required)
- **Configuration**: Fully automated via EC2 user data script

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
