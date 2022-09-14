
// s3 bucket for lambda function artifact
resource "aws_s3_bucket" "this" {
  bucket = var.s3_bucket_name
}
