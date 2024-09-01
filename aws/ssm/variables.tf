variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
}
variable "prefix" {
  default     = "mcs-compute"
  description = "Name tag prefix for all created resources"
  type        = string
}
