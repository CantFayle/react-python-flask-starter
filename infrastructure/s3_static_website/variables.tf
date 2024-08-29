variable "bucket_name" {
  type = string
  description = "Bucket name of S3 static website"
}

variable "bucket_description" {
  type = string
  description = "Bucket description"
}

variable "index_document" {
  type = string
  default = "index.html"
  description = "Default index document, usually index.html"
}

variable "environment" {
  type = string
  description = "Environment to deploy to"
}

variable "cloudfront_domain_name" {
  type = string
  description = "CloudFront Distribution URL, used to prevent refresh breaking"
}

variable "cloudfront_arn" {
  type = string
  description = "CloudFront Distribution ARN"
}