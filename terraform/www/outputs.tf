output "s3_first_bucket_arn" {
  description = "S3 first Bucket ARN"
  value = module.s3_first.arn
}

output "s3_first_bucket_name" {
  description = "S3 first Bucket NAME"
  value = module.s3_first.name
}

output "website_endpoint" {
  description = "The public url of this website."
  value = "${module.s3_first.website_endpoint}"
}


