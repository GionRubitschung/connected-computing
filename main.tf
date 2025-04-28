terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "cc-bfh-student16-tf-state"
    key     = "terraform/state"
    region  = "eu-central-1"
    profile = "tf-student16"
  }
}

provider "aws" {
  region  = "eu-central-1"
  profile = "tf-student16"
}

# S3 bucket for Lambda results
resource "aws_s3_bucket" "result_bucket" {
  bucket = "cc-bfh-student16-result"
  force_destroy = true

  tags = {
    Owner   = "student16"
    Project = "iac-lab"
  }
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "cc-bfh-student16-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Owner   = "student16"
    Project = "iac-lab"
  }
}

# IAM policy for Lambda to write to S3
resource "aws_iam_policy" "lambda_policy" {
  name        = "cc-bfh-student16-lambda-policy"
  description = "Policy for Lambda to write to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
          "${aws_s3_bucket.result_bucket.arn}",
          "${aws_s3_bucket.result_bucket.arn}/*"
        ]
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })

  tags = {
    Owner   = "student16"
    Project = "iac-lab"
  }
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Lambda function
resource "aws_lambda_function" "s3_writer_lambda" {
  filename      = "lambda_function.zip"
  function_name = "cc-bfh-student16-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda.handler"
  runtime       = "python3.12"

  tags = {
    Owner   = "student16"
    Project = "iac-lab"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment,
    data.archive_file.lambda_zip
  ]
}

# Create zip file for Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda.py"
  output_path = "${path.module}/lambda_function.zip"
}
