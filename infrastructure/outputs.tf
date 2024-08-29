output "cloudfront_distribution_id" {
  value = module.cloudfront.distribution_id
}

output "s3_static_site_bucket_name" {
  value = local.website_bucket_name
}

output "cloudfront_url" {
  value = module.cloudfront.domain_name
}