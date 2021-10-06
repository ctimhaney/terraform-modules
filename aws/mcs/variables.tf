variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
}
variable "prefix" {
  default     = "mcs-compute"
  description = "Name tag prefix for all created resources"
  type        = string
}
variable "vpc_id" {
  description = "The VPC identifier to place compute resources"
  type        = string
}
variable "ami_id" {
  description = "Amazon MAchine Image ID to use in the launch template"
  type        = string
}
variable "ebs_volume_size" {
  default     = 50
  description = "size of the EBS volume to mount"
  type        = number
}
variable "instance_type" {
  description = "Amazon Instance type (or class)"
  type        = string
}
variable "key_name" {
  description = "EC2 key name to authorize on ECS compute resources"
  type        = string
}
variable "vpc_asg_subnets" {
  description = "List of Subnet IDs where the autoscaling group will deploy compute resources"
  type = list(string)
}

variable "vpc_lb_subnets" {
  description = "Subnet IDs where the LB will reside"
  type        = list(string)
}
 variable "iam_instance_profile_name" {
   default = ""
   description = "The name of the iam instance profile to attach to instances"
   type = string
 }
