locals {
  resource_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(var.mandatory_tags, {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  })
}

module "aws" {
  source = "./modules/aws"
  count  = var.cloud == "aws" ? 1 : 0

  name_prefix       = local.resource_prefix
  cidr_block        = var.cidr_block
  subnet_cidr_block = var.subnet_cidr_block
  tags              = local.common_tags
}

module "azure" {
  source = "./modules/azure"
  count  = var.cloud == "azure" ? 1 : 0

  name_prefix       = local.resource_prefix
  location          = var.azure_location
  cidr_block        = var.cidr_block
  subnet_cidr_block = var.subnet_cidr_block
  tags              = local.common_tags
}

module "gcp" {
  source = "./modules/gcp"
  count  = var.cloud == "gcp" ? 1 : 0

  name_prefix       = local.resource_prefix
  region            = var.gcp_region
  cidr_block        = var.cidr_block
  subnet_cidr_block = var.subnet_cidr_block
  labels            = local.common_tags
}
