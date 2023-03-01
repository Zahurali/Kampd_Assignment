resource "aws_s3_bucket" "artifacts" {
  bucket = "artifacts"
}

resource "aws_s3_bucket_acl" "artifacts_acl" {
  bucket = aws_s3_bucket.artifacts.id
  acl    = "private"
}