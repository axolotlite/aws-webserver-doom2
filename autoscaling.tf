
resource "aws_launch_configuration" "this" {
  name_prefix   = "${var.project_name}-lc-"
  image_id      = data.aws_ami.ubuntu.id  # Replace with your desired AMI ID
  instance_type = "t2.small"
  key_name = "tf-key-pair"
  security_groups = [aws_security_group.master.id]
  user_data = data.template_file.npm_app.rendered

  lifecycle {
    create_before_destroy = true
  }
}

# Create an Auto Scaling Group
resource "aws_autoscaling_group" "this" {
  name              = "${var.project_name}-asg"
  min_size          = 1
  max_size          = 3
  desired_capacity  = 2
  launch_configuration = aws_launch_configuration.this.name
  vpc_zone_identifier = [aws_subnet.public.id]  # Replace with your desired subnet ID(s)
  load_balancers = [aws_elb.this.id]
  depends_on = [ aws_s3_bucket.build_bucket, aws_s3_bucket_object.build_archive ]
}

# Create an Elastic Load Balancer
resource "aws_elb" "this" {
  name               = "${var.project_name}-elb"
  security_groups    = [aws_security_group.master.id]
  subnets = [aws_subnet.public.id]
#   availability_zones = ["us-east-1a"]  # Replace with your desired availability zones
  listener {
    instance_port     = var.default_port
    instance_protocol = "http"
    lb_port           = var.default_port
    lb_protocol       = "http"
  }

  health_check {
    target              = "HTTP:${var.default_port}/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }
  depends_on = [ aws_s3_bucket.build_bucket, aws_s3_bucket_object.build_archive ]
}