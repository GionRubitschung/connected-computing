# Event-Driven Terraform Setup with AWS Lambda

This repository contains Terraform configurations to set up an AWS Lambda function that writes files to an S3 bucket.

## Prerequisites

- AWS CLI configured with `tf-student16` profile
- Terraform installed
- Python 3.12

## Infrastructure Components

- S3 bucket: `cc-bfh-student16-result` (for Lambda output)
- Lambda function: `cc-bfh-student16-lambda`
- IAM role with appropriate permissions

## Setting Up the Terraform Backend

Before initializing Terraform, you need to create an S3 bucket to store the Terraform state files:

```bash
aws s3 mb s3://cc-bfh-student16-tf-state --profile tf-student16
```

Enable versioning on the bucket to keep state file history:

```bash
aws s3api put-bucket-versioning --bucket cc-bfh-student16-tf-state --versioning-configuration Status=Enabled --profile tf-student16
```

## Deployment Instructions

1. Initialize Terraform with the S3 backend:

```bash
terraform init \
  -backend-config="bucket=cc-bfh-student16-tf-state" \
  -backend-config="key=terraform.tfstate" \
  -backend-config="region=eu-central-1" \
  -backend-config="profile=tf-student16"
```

2. Plan the deployment to verify changes:

```bash
terraform plan
```

3. Apply the Terraform configuration:

```bash
terraform apply
```

4. To destroy the infrastructure when done:

```bash
terraform destroy
```

## Automation Script

For convenience, an automation script `terraform.sh` is provided that handles the entire workflow from setup to testing:

```bash
# Make the script executable
chmod +x terraform.sh

./terraform.sh
```

### What the Script Does

The script automates the following tasks:
1. Checks if the S3 state bucket exists and creates it if needed
2. Enables versioning on the bucket if not already enabled
3. Initializes Terraform with the correct backend configuration
4. Plans and applies the Terraform configuration
5. Tests the Lambda function with a sample payload
6. Lists and retrieves the created file from the result bucket
7. Optionally destroys the infrastructure

Each step displays informative messages to show what's happening.

## Testing the Lambda Function

Invoke the Lambda function with a test payload:

```bash
aws lambda invoke \
  --function-name cc-bfh-student16-lambda \
  --payload '{"filename":"example.txt","filetext":"This is a test"}' \
  --cli-binary-format raw-in-base64-out \
  --profile tf-student16 \
  ./output/response.json
```

Verify the output in the S3 bucket:

```bash
aws s3 ls s3://cc-bfh-student16-result --profile tf-student16
```

To download and view the created file:

```bash
aws s3 cp s3://cc-bfh-student16-result/example.txt ./output --profile tf-student16
cat ./output/example.txt
```

## Lambda Function Details

The Lambda function accepts a JSON payload with two parameters:
- `filename`: Name of the file to create in S3
- `filetext`: Content of the file

Example payload:
```json
{
  "filename": "example.txt",
  "filetext": "This is a test"
}
```
