# AWS Module

This module creates basic networking infrastructure in AWS.

## Resources Created

- VPC with DNS support and hostnames enabled
- Subnet in the first availability zone
- All resources tagged according to governance requirements

## Usage

```hcl
module "aws" {
  source = "./modules/aws"

  name_prefix       = "my-project-dev"
  cidr_block        = "10.42.0.0/16"
  subnet_cidr_block = "10.42.1.0/24"
  tags = {
    owner       = "platform-team"
    cost_center = "cc-001"
    compliance  = "baseline"
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| name_prefix | Prefix for resource names | string | yes |
| cidr_block | VPC CIDR block | string | yes |
| subnet_cidr_block | Subnet CIDR block | string | yes |
| tags | Tags to apply to all resources | map(string) | yes |

## Outputs

| Name | Description |
|------|-------------|
| network_id | VPC ID |
| subnet_id | Subnet ID |

## Requirements

- Terraform >= 1.6.0
- AWS provider ~> 5.0
