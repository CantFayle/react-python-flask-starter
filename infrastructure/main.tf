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
  app_name            = format("%s %s", var.app_name, terraform.workspace)
  # table_name          = format("%s-%s", var.dynamo_table_name, terraform.workspace)
}

module "s3_static_website" {
  source                  = "./s3_static_website"
  bucket_name             = local.website_bucket_name
  bucket_description      = local.app_name
  environment             = terraform.workspace
  cloudfront_domain_name  = module.cloudfront.domain_name
  cloudfront_arn          = module.cloudfront.arn
}

module "cloudfront" {
  source              = "./cloudfront"
  region              = var.region
  bucket_name         = local.website_bucket_name
  bucket_description  = local.app_name
}