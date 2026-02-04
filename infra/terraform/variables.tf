variable "cloud" {
  description = "Target cloud provider: aws, azure, gcp"
  type        = string

  validation {
    condition     = contains(["aws", "azure", "gcp"], var.cloud)
    error_message = "cloud must be one of: aws, azure, gcp"
  }
}

variable "project_name" {
  description = "Logical project/application name"
  type        = string
  default     = "dissertation-pipeline"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "cidr_block" {
  description = "VPC/VNet network CIDR"
  type        = string
  default     = "10.42.0.0/16"
}

variable "subnet_cidr_block" {
  description = "Subnet CIDR"
  type        = string
  default     = "10.42.1.0/24"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "azure_location" {
  description = "Azure location"
  type        = string
  default     = "eastus"
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
  default     = "replace-me"
}

variable "mandatory_tags" {
  description = "Governance tags required on all resources"
  type        = map(string)
  default = {
    owner       = "platform-team"
    cost_center = "cc-001"
    compliance  = "baseline"
  }
}
