# Create a bucket
resource "aws_s3_bucket" "build_bucket" {
  bucket = "s3-steins-gate-round-table-app-bucket"
}
resource "aws_s3_bucket_public_access_block" "public_bucket" {
  bucket = aws_s3_bucket.build_bucket.id

  block_public_acls   = false
  block_public_policy = false
}
resource "aws_s3_bucket_policy" "build_bucket_policy" {
  bucket = aws_s3_bucket.build_bucket.id
  policy = template_file.s3_public_read_policy.rendered
}
#upload directory to bucket
resource "aws_s3_bucket_object" "build_archive" {
    bucket = aws_s3_bucket.build_bucket.id
    source = "${var.build_directory}"
    key="build.zip"
}