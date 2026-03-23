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
  description = "VNet network CIDR"
  type        = string
  default     = "10.42.0.0/16"
}

variable "subnet_cidr_block" {
  description = "Subnet CIDR"
  type        = string
  default     = "10.42.1.0/24"
}

variable "azure_location" {
  description = "Azure location"
  type        = string
  default     = "eastus"
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
