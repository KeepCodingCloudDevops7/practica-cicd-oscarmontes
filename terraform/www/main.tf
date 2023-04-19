module "s3_first" {
  source = "../modules/aws/s3"

  bucket_name = var.s3_bucket
}
