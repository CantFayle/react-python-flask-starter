variable "website_bucket_name" {
  type    = string
  default = "react-starter"
  description = "Bucket name of S3 static website"
}

variable "app_name" {
  type    = string
  default = "React Starter"
  description = "Bucket description for S3 static website"
}

variable "region" {
  type    = string
  default = "eu-west-2"
  description = "AWS Region"
}