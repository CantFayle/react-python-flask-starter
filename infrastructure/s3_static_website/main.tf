resource "aws_s3_bucket" "fe_client_bucket" {
  bucket = var.bucket_name
  tags = {
    Name        = var.bucket_description
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = var.bucket_name

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "cloudfront_bucket_policy" {
  bucket = var.bucket_name
  policy = <<EOF
    {
      "Id": "PolicyForCloudFrontPrivateContent",
      "Statement": [
        {
          "Action": "s3:GetObject",
          "Condition": {
            "StringEquals": {
              "AWS:SourceArn": "${var.cloudfront_arn}"   
            }
          },
          "Effect": "Allow",
          "Principal": {
            "Service": "cloudfront.amazonaws.com"
          },
          "Resource": "arn:aws:s3:::${var.bucket_name}/*",
          "Sid": "AllowCloudFrontServicePrincipal"
        }
      ],
      "Version": "2008-10-17"
    }
  EOF
}