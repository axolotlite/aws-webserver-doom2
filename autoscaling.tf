
resource "aws_launch_configuration" "nginx_lc" {
  name_prefix   = "nginx-lc-"
  image_id      = data.aws_ami.ubuntu.id  # Replace with your desired AMI ID
  instance_type = "t2.small"
  key_name = "tf-key-pair"
  security_groups = [aws_security_group.master.id]
  user_data = file("docker_init.sh")

  lifecycle {
    create_before_destroy = true
  }
}

# Create an Auto Scaling Group
resource "aws_autoscaling_group" "nginx_asg" {
  name              = "nginx-asg"
  min_size          = 1
  max_size          = 3
  desired_capacity  = 2
  launch_configuration = aws_launch_configuration.nginx_lc.name
  vpc_zone_identifier = [aws_subnet.public.id]  # Replace with your desired subnet ID(s)
  load_balancers = [aws_elb.nginx_elb.id]
}

# Create an Elastic Load Balancer
resource "aws_elb" "nginx_elb" {
  name               = "nginx-elb"
  security_groups    = [aws_security_group.master.id]
  subnets = [aws_subnet.public.id]
#   availability_zones = ["us-east-1a"]  # Replace with your desired availability zones
  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 8000
    lb_protocol       = "http"
  }

  health_check {
    target              = "HTTP:8000/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }
}