data "aws_ami" "ubuntu" {

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220912"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}
data "template_file" "npm_app" {
  template = "${file("scripts/npm_app.tpl")}"

  vars = {
    bucket_name = "${aws_s3_bucket.build_bucket.id}"
    default_port = data.default_port
  }
}