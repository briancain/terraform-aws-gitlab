#!/bin/bash
set -e

# Check if AWS_PROFILE is set
if [ -z "${AWS_PROFILE}" ]; then
  echo "❌ Error: AWS_PROFILE environment variable is not set"
  echo ""
  echo "Please set AWS_PROFILE before running this script:"
  echo "  export AWS_PROFILE=your-profile-name"
  exit 1
fi

# Configuration
AWS_REGION="us-west-2"
BUCKET_NAME="terraform-state-gitlab-${AWS_REGION}"
DYNAMODB_TABLE="terraform-state-lock-gitlab"

echo "Setting up Terraform backend infrastructure..."
echo "AWS Profile: ${AWS_PROFILE}"
echo "Region: ${AWS_REGION}"
echo ""

# Create S3 bucket for Terraform state
echo "Creating S3 bucket: ${BUCKET_NAME}"
aws s3api create-bucket \
  --bucket "${BUCKET_NAME}" \
  --region "${AWS_REGION}" \
  --create-bucket-configuration LocationConstraint="${AWS_REGION}" \
  2>/dev/null || echo "Bucket already exists"

# Enable versioning on the bucket
echo "Enabling versioning on S3 bucket..."
aws s3api put-bucket-versioning \
  --bucket "${BUCKET_NAME}" \
  --versioning-configuration Status=Enabled

# Enable encryption
echo "Enabling encryption on S3 bucket..."
aws s3api put-bucket-encryption \
  --bucket "${BUCKET_NAME}" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Create DynamoDB table for state locking
echo "Creating DynamoDB table: ${DYNAMODB_TABLE}"
aws dynamodb create-table \
  --table-name "${DYNAMODB_TABLE}" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "${AWS_REGION}" \
  2>/dev/null || echo "Table already exists"

# Generate backend.tf
echo "Generating backend.tf..."
cat > backend.tf <<EOF
terraform {
  backend "s3" {
    bucket         = "${BUCKET_NAME}"
    key            = "gitlab/terraform.tfstate"
    region         = "${AWS_REGION}"
    dynamodb_table = "${DYNAMODB_TABLE}"
    encrypt        = true
  }
}
EOF

echo ""
echo "✅ Terraform backend setup complete!"
echo ""
echo "Backend configuration:"
echo "  Bucket: ${BUCKET_NAME}"
echo "  DynamoDB Table: ${DYNAMODB_TABLE}"
echo "  Region: ${AWS_REGION}"
echo ""
echo "Generated backend.tf file"
echo ""
echo "You can now run: terraform init"
