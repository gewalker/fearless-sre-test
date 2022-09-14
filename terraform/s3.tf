
// s3 bucket for lambda function artifact
resource "aws_s3_bucket" "this" {
  bucket = "var.bucket_name"
}
