variable "website_bucket_name" {
  type        = string
  default     = "react-starter"
  description = "Bucket name of S3 static website"
}

variable "app_name" {
  type        = string
  default     = "React Starter App"
  description = "Name of app"
}

variable "region" {
  type        = string
  default     = "eu-west-2"
  description = "AWS Region"
}

variable "dynamo_table_name" {
  type        = string
  default     = "dynamo-table"
  description = "Name of DynamoDB table"
}