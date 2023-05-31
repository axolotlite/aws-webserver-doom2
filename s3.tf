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

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::s3-steins-gate-round-table-app-bucket/*"
        }
    ]
}
POLICY
}
#upload directory to bucket
resource "aws_s3_bucket_object" "build_archive" {
    source = "${var.build_directory}"
    key="build.zip"
}