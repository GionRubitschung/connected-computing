#!/bin/bash

echo "Checking if S3 bucket for Terraform state exists..."
if aws s3api head-bucket --bucket cc-bfh-student16-tf-state --profile tf-student16 2>/dev/null; then
  echo "Bucket already exists, skipping creation"
else
  echo "Creating S3 bucket for Terraform state..."
  aws s3 mb s3://cc-bfh-student16-tf-state --profile tf-student16
fi

echo "Checking bucket versioning status..."
VERSIONING_STATUS=$(aws s3api get-bucket-versioning --bucket cc-bfh-student16-tf-state --profile tf-student16 --query 'Status' --output text 2>/dev/null)
if [ "$VERSIONING_STATUS" = "Enabled" ]; then
  echo "Versioning already enabled, skipping configuration"
else
  echo "Enabling versioning on the S3 bucket..."
  aws s3api put-bucket-versioning --bucket cc-bfh-student16-tf-state --versioning-configuration Status=Enabled --profile tf-student16
fi

echo "Initializing Terraform with remote backend..."
terraform init \
  -backend-config="bucket=cc-bfh-student16-tf-state" \
  -backend-config="key=terraform.tfstate" \
  -backend-config="region=eu-central-1" \
  -backend-config="profile=tf-student16"

echo "Planning Terraform changes..."
terraform plan

echo "Applying Terraform configuration..."
terraform apply

echo "Invoking Lambda function with test payload..."
aws lambda invoke \
  --function-name cc-bfh-student16-lambda \
  --payload '{"filename":"example.txt","filetext":"This is a test"}' \
  --cli-binary-format raw-in-base64-out \
  --profile tf-student16 \
  response.json

echo "Listing contents of result S3 bucket..."
aws s3 ls s3://cc-bfh-student16-result --profile tf-student16

echo "Downloading created file from S3..."
aws s3 cp s3://cc-bfh-student16-result/example.txt . --profile tf-student16
echo "Content of the created file:"
cat example.txt

echo "Destroying Terraform infrastructure..."
terraform destroy