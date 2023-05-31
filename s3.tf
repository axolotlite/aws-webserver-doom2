# Create a bucket
resource "aws_s3_bucket" "build-bucket" {
  bucket = "s3-steins-gate-round-table-app-bucket"

  acl    = "public-read"   # or can be "public-read"
}
#upload directory to bucket
resource "aws_s3_bucket_object" "object1" {
for_each = fileset("${var.build_directory}/", "*")
bucket = aws_s3_bucket.bucket.id
key = each.value
source = "${var.build_directory}/${each.value}"
etag = filemd5("${var.build_directory}/${each.value}")
}