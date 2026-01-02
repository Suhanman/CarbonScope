resource "aws_launch_template" "cloudami_template" {
  name_prefix = "cloudami-"

  image_id = "ami-05db56a8ea18b4dc5"  
  instance_type = var.instance_type
  key_name = var.app_key_name

  network_interfaces {
    security_groups = [var.ec2_sg_id]
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 10
      volume_type           = "gp3"
      delete_on_termination = false
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "cloudami"
    }
  }
}

resource "aws_instance" "app" {
  launch_template {
    id      = aws_launch_template.cloudami_template.id
    version = "$Latest"
  }
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_ids["public-subnet-a"]
  vpc_security_group_ids      = [var.ec2_sg_id]
  associate_public_ip_address = true
  iam_instance_profile        = var.app_instance_profile
  key_name                    = var.app_key_name

   root_block_device {
    volume_size = 10        # 루트 EBS 크기 (GB)
    volume_type = "gp3"
    delete_on_termination = false 
  }

  tags = {
    Name = "app-ec2"
  }
}

