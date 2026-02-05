variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "cidr_block" {
  description = "VPC CIDR block"
  type        = string
}

variable "subnet_cidr_block" {
  description = "Subnet CIDR block"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}
