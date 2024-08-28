output "cloudfront_distribution_id" {
  value = module.CloudFront.distribution_id
}

output "s3_static_site_bucket_name" {
  value = local.bucket_name
}