# Create a bucket
resource "aws_s3_bucket" "build_bucket" {
  bucket = "s3-steins-gate-round-table-app-bucket"
}
resource "aws_s3_bucket_public_access_block" "public_bucket" {
  bucket = aws_s3_bucket.build_bucket.id

  block_public_acls   = false
  block_public_policy = false
}
#upload directory to bucket
resource "aws_s3_bucket_object" "object1" {
for_each = fileset("${var.build_directory}/", "*")
bucket = aws_s3_bucket.build_bucket.id
key = each.value
source = "${var.build_directory}/${each.value}"
etag = filemd5("${var.build_directory}/${each.value}")
}