# Azure Module

This module creates basic networking infrastructure in Azure.

## Resources Created

- Resource Group
- Virtual Network
- Subnet
- All resources tagged according to governance requirements

## Usage

```hcl
module "azure" {
  source = "./modules/azure"

  name_prefix       = "my-project-dev"
  location          = "eastus"
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
| location | Azure region location | string | yes |
| cidr_block | VNet CIDR block | string | yes |
| subnet_cidr_block | Subnet CIDR block | string | yes |
| tags | Tags to apply to all resources | map(string) | yes |

## Outputs

| Name | Description |
|------|-------------|
| network_id | Virtual Network ID |
| subnet_id | Subnet ID |

## Requirements

- Terraform >= 1.6.0
- AzureRM provider ~> 3.0
