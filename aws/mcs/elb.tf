# resource "aws_lb" "mcs" {
#   load_balancer_type = "network"
#   internal = false
#   subnets = var.vpc_lb_subnets
#   tags = {
#     Name = "${var.prefix} NLB"
#   }
# }
#
# resource "aws_lb_target_group" "mcs" {
#   health_check {
#     port = 25565
#     protocol = "TCP"
#   }
#   port = 25565
#   protocol = "TCP"
#   tags = {
#     Name = "${var.prefix} Target Group"
#   }
#   target_type = "instance"
#   vpc_id = var.vpc_id
# }
#
# resource "aws_lb_listener" "mcs" {
#   default_action {
#     target_group_arn = aws_lb_target_group.mcs.arn
#     type = "forward"
#   }
#   load_balancer_arn = aws_lb.mcs.arn
#   port = 25565
#   protocol = "TCP"
#   tags = {
#     Name = "${var.prefix} Listener"
#   }
# }
