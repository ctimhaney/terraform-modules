variable "aws_region" {
  default     = "us-east-2"
  type        = string
  description = "AWS region to deploy to"
}

variable "prefix" {
  default     = "chaney-dev"
  type        = string
  description = "Name tag prefix"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  type        = string
  description = "VPC CIDR block"
}

# TODO calculate subnet lists based off counts
variable "internal_subnets" {
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  type        = list(string)
  description = "VPC internal subnet CIDR list"
}

variable "external_subnets" {
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
  type        = list(string)
  description = "VPC external subnet CIDR list"
}

variable "availability_zones" {
  default     = ["us-east-2a", "us-east-2b"]
  type        = list(string)
  description = "The AZ to use for the primary subnet"
}

variable "external_nacl_ingress" {
  default = []
  type = list(object({
    protocol   = string,
    cidr_block = string,
    from_port  = string,
    to_port    = string
  }))
  description = "List of ingress rules to allow on external subnets"
}

variable "external_nacl_egress" {
  default = []
  type = list(object({
    protocol   = string,
    cidr_block = string,
    from_port  = string,
    to_port    = string
  }))
}
variable "internal_nacl_ingress" {
  default = []
  type = list(object({
    protocol   = string,
    cidr_block = string,
    from_port  = string,
    to_port    = string
  }))
}
variable "internal_nacl_egress" {
  default = []
  type = list(object({
    protocol   = string,
    cidr_block = string,
    from_port  = string,
    to_port    = string
  }))
}
