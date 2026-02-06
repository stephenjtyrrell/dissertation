variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "cidr_block" {
  description = "VPC CIDR block (not used in GCP but kept for consistency)"
  type        = string
}

variable "subnet_cidr_block" {
  description = "Subnet CIDR block"
  type        = string
}

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
}
