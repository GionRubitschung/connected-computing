import json
import boto3


def handler(event, context):
    s3 = boto3.client("s3")

    filename = event.get("filename")
    filetext = event.get("filetext")

    if not filename or not filetext:
        return {
            "statusCode": 400,
            "body": json.dumps("Missing required parameters: filename or filetext"), # noqa
        }

    bucket_name = "cc-bfh-student16-result"

    try:
        s3.put_object(Bucket=bucket_name, Key=filename, Body=filetext)

        return {
            "statusCode": 200,
            "body": json.dumps(
                {
                    "message": "File successfully written to S3",
                    "bucket": bucket_name,
                    "filename": filename,
                }
            ),
        }
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps(
                {"message": "Error writing file to S3", "error": str(e)}
            ),
        }
