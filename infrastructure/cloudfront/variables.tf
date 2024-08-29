variable "region" {
  type = string
  description = "AWS Region"
}

variable "bucket_name" {
  type = string
  description = "Bucket name of S3 static website"
}

variable "bucket_description" {
  type = string
  description = "Bucket description for S3 static website"
}