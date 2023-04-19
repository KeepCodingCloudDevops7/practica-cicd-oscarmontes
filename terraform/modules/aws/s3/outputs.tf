output "name" {
  description = "bucket name"
  value = aws_s3_bucket.this.bucket
}

output "arn" {
  description = "bucket ARN"
  value = aws_s3_bucket.this.arn
}

output "website_endpoint" {
  description = "The public url of this website."
  value = "${aws_s3_bucket.this.website_endpoint}"
}
