resource "aws_security_group" "mcs" {
  description = "Allow instance traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.prefix} ECS Compute SG"
  }
}

resource "aws_security_group_rule" "mcs_ingress" {
  type              = "ingress"
  description       = "Load Balancer ingress"
  from_port         = 25565
  to_port           = 25565
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.mcs.cidr_block]
  security_group_id = aws_security_group.mcs.id
}

resource "aws_security_group_rule" "mcs_egress" {
  type              = "egress"
  description       = "Load Balancer egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.mcs.id
}

resource "aws_security_group_rule" "mcs_source_sg" {
  count = length(var.source_security_groups)
  type = "ingress"
  protocol = var.source_security_groups[count.index].protocol
  description = "ingress soruce SG"
  from_port = var.source_security_groups[count.index].from_port
  to_port = var.source_security_groups[count.index].to_port
  source_security_group_id = var.source_security_groups[count.index].id
  security_group_id = aws_security_group.mcs.id
}

resource "aws_launch_template" "mcs" {
  description = "Launch template for MCS ECS compute"
  # block_device_mappings {
  #   device_name = "/dev/sda1"
  #
  #   ebs {
  #     # encrypted = true?
  #     # kms_key_id
  #     volume_size = var.ebs_volume_size
  #     volume_type = "gp3"
  #   }
  # }
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }
  image_id      = var.ami_id
  instance_type = var.instance_type

  key_name = var.key_name

  vpc_security_group_ids = [
    aws_security_group.mcs.id
  ]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.prefix} ECS Compute"
    }
  }

  tags = {
    Name = "${var.prefix} Launch Template"
  }

  user_data = filebase64("${path.module}/user_data.sh")
}

resource "aws_autoscaling_group" "mcs" {
  max_size         = 1
  min_size         = 1
  desired_capacity = 1
  launch_template {
    id      = aws_launch_template.mcs.id
    version = "$Latest"
  }
  vpc_zone_identifier = var.vpc_asg_subnets
  # target_group_arns = [
  #   aws_lb_target_group.mcs.arn
  # ]
  tags = [
    {
      Name = "${var.prefix} Auto Scaling Group"
    }
  ]
}
