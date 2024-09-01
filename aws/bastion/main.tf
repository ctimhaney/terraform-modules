resource "aws_security_group" "bastion" {
  description = "Allow SSH traffic to bastion"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.prefix} Bastion SG"
  }
}

resource "aws_security_group_rule" "bastion_ingress" {
  count = length(var.source_ssh_cidr)
  type              = "ingress"
  description       = "Bastion ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.source_ssh_cidr[count.index]]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_egress" {
  type              = "egress"
  description       = "Bastion egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_launch_template" "bastion" {
  description = "Launch template for a dedicated bastion fleet"
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }
  image_id      = var.ami_id
  instance_type = var.instance_type

  key_name = var.key_name
  vpc_security_group_ids = [
    aws_security_group.bastion.id
  ]
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.prefix} Bastion"
    }
  }
  tags = {
    Name = "${var.prefix} Launch Template"
  }
}

resource "aws_autoscaling_group" "bastion" {
  max_size         = var.max_size
  min_size         = 1
  desired_capacity = var.desired_capacity
  launch_template {
    id      = aws_launch_template.bastion.id
    version = "$Latest"
  }
  vpc_zone_identifier = var.vpc_asg_subnets
  tags = [
    {
      Name = "${var.prefix} Auto Scaling Group"
    }
  ]
}
# TODO EIP? IAM role to allow ssh access from bastion?
