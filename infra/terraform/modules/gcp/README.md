# GCP Module

This module creates basic networking infrastructure in Google Cloud Platform.

## Resources Created

- VPC Network (custom mode, no auto-created subnets)
- Subnet with specified CIDR range
- Note: GCP networks don't support labels directly; labels are applied at project or resource level for supported resources

## Usage

```hcl
module "gcp" {
  source = "./modules/gcp"

  name_prefix       = "my-project-dev"
  region            = "us-central1"
  cidr_block        = "10.42.0.0/16"
  subnet_cidr_block = "10.42.1.0/24"
  labels = {
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
| region | GCP region | string | yes |
| cidr_block | VPC CIDR block (not used in GCP but kept for consistency) | string | yes |
| subnet_cidr_block | Subnet CIDR block | string | yes |
| labels | Labels to apply to all resources | map(string) | yes |

## Outputs

| Name | Description |
|------|-------------|
| network_id | VPC Network ID |
| subnet_id | Subnet ID |

## Requirements

- Terraform >= 1.6.0
- Google provider ~> 5.0
