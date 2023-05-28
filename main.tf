resource "aws_instance" "this" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.small"
  vpc_security_group_ids      = [aws_security_group.master.id]
  subnet_id                   = aws_subnet.public.id
  key_name                    = "tf-key-pair"
  # user_data                   = file("web_init.sh")
  tags = {
    Name = "web"
  }
  
  provisioner "remote-exec" {
    inline = ["sudo apt update"]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.rsa.private_key_pem
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i '${self.public_ip},' --private-key 'tf-key-pair.pem' -e 'pub_key=${aws_key_pair.tf-key-pair.public_key}' ansible-playbooks/lemp_ubuntu1804/playbook.yml"
  }
}

resource "aws_key_pair" "tf-key-pair" {
  key_name   = "tf-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "${path.module}/tf-key-pair.pem"
  file_permission = "0400"
}

resource "aws_volume_attachment" "this" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.this.id
  instance_id = aws_instance.this.id
}

resource "aws_ebs_volume" "this" {
  availability_zone = "us-east-1a"
  size              = 30

  tags = {
    Name = "web"
  }
}

resource "aws_ebs_snapshot" "this" {
  volume_id = aws_ebs_volume.this.id

  tags = {
    Name = "web_snap"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}

resource "aws_cloudfront_distribution" "this" {
  enabled = true
  origin {
    domain_name = aws_instance.this.public_dns
    origin_id   = aws_instance.this.public_dns
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = aws_instance.this.public_dns
    viewer_protocol_policy = "redirect-to-https" # other options - https only, http
    forwarded_values {
      headers      = []
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = {
    Environment = var.env
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
