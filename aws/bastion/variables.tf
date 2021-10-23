variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
}
variable "prefix" {
  default     = "mcs-compute"
  description = "Name tag prefix for all created resources"
  type        = string
}
variable "ingress_cidrs" {
  type        = list(string)
  default     = []
  description = "List of CIDR ranges to "
}

variable "ami_id" {
  type        = string
  description = "AMI ID to use for the bastion host"
}
variable "instance_type" {
  description = "Amazon Instance type (or class)"
  type        = string
}
variable "key_name" {
  description = "EC2 key name to authorize on ECS compute resources"
  type        = string
}
variable "vpc_id" {
  description = "The VPC identifier to place compute resources"
  type        = string
}

variable "iam_instance_profile_name" {
  default     = ""
  description = "The name of the iam instance profile to attach to instances"
  type        = string
}

variable "max_size" {
  default     = 1
  type        = number
  description = "Maximum number of bastion hosts"
}

variable "desired_capacity" {
  default     = 1
  type        = number
  description = "desired number of bastion hosts"
}

variable "vpc_asg_subnets" {
  description = "List of Subnet IDs where the autoscaling group will deploy compute resources"
  type        = list(string)
}

variable "source_ssh_cidr" {
  type = list(string)
  description = "a list of CIDR blocks to authorize security group SSH ingress"
  default = []
}
