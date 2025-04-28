output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.s3_writer_lambda.function_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for results"
  value       = aws_s3_bucket.result_bucket.bucket
}

output "lambda_invoke_command" {
  description = "Command to invoke the Lambda function"
  value       = "aws lambda invoke --function-name ${aws_lambda_function.s3_writer_lambda.function_name} --payload '{\"filename\":\"example.txt\",\"filetext\":\"This is a test\"}' --cli-binary-format raw-in-base64-out --profile tf-student16 response.json"
}
