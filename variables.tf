variable "environment" {
  type        = "string"
  description = "The environment that these resources are for"
  default     = "test"
}

# network variables
variable "aws_region" {
  type        = "string"
  description = "The AWS region that the VPC will be created in. The default is ca-central-1."
  default     = "ca-central-1"
}

variable "vpc_cidr_block" {
  type        = "string"
  description = "The CIDR block that will reside in the VPC. The default is 10.100.0.0/16"
  default     = "10.100.0.0/16"
}

variable "public_cidr_blocks" {
  type        = "list"
  description = "The list of CIDR blocks that will be used for the edge subnets (where all publicly accessible resources will be placed). The default is ['10.100.254.0/25', '10.100.254.128/25']. "

  default = [
    "10.100.254.0/25",
    "10.100.254.128/25",
  ]
}

variable "private_cidr_blocks" {
  type        = "list"
  description = "The list of CIDR blocks that will be used for private subnets. The default value is ['10.100.10.0/24','10.100.11.0/24']."

  default = [
    "10.100.10.0/24",
    "10.100.11.0/24",
  ]
}
