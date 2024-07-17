resource "aws_s3_bucket" "fe_client_bucket" {
  bucket = var.website_bucket_name
  tags = {
    Name        = var.bucket_description
    Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.fe_client_bucket.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": [
                "arn:aws:s3:::${var.website_bucket_name}",
                "arn:aws:s3:::${var.website_bucket_name}/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
EOF
}

resource "aws_s3_bucket_website_configuration" "website-config" {
  bucket = aws_s3_bucket.fe_client_bucket.bucket
  index_document {
    suffix = var.index_document
  }
  error_document {
    key = var.index_document
  }
  routing_rules = <<EOF
[{
    "Condition": {
        "HttpErrorCodeReturnedEquals": "404"
    },
    "Redirect": {
        "HostName": "${var.cloudfront_domain_name}",
        "ReplaceKeyWith": ""
    }
}]
EOF
}