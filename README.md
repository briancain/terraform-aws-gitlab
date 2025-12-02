# GitLab on AWS - Terraform

Simple GitLab Community Edition deployment on AWS for testing and API integration.

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
