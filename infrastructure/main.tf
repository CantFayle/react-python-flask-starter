terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "conorfayle-terraform-state"
    key    = "react-flask-starter"
    region = "eu-west-2"
  }
  required_version = ">= 1.7"
}

provider "aws" {
  region = var.region
}

locals {
  website_bucket_name = format("%s-%s", var.website_bucket_name, terraform.workspace)
  app_name = format("%s %s", var.app_name, terraform.workspace)
  table_name  = format("%s-%s", var.dynamo_table_name, terraform.workspace)
}

module "S3_Static_Website" {
  source                 = "./S3_Static_Website"
  website_bucket_name    = local.website_bucket_name
  bucket_description     = var.app_name
  environment            = terraform.workspace
  cloudfront_domain_name = module.CloudFront.domain_name
}

module "CloudFront" {
  source              = "./CloudFront"
  region              = var.region
  website_bucket_name = local.website_bucket_name
}

# resource "aws_dynamodb_table" "dynamo_table" {
#   name           = local.table_name
#   billing_mode   = "PAY_PER_REQUEST"
#   hash_key       = "user_id"

#   attribute {
#     name = "user_id"
#     type = "N"
#   }

#   tags = {
#     Name        = var.dynamo_table_name
#     Environment = terraform.workspace
#   }
# }
