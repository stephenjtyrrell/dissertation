locals {
  resource_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(var.mandatory_tags, {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  })
}

module "aws" {
  source = "../modules/aws"

  name_prefix       = local.resource_prefix
  cidr_block        = var.cidr_block
  subnet_cidr_block = var.subnet_cidr_block
  tags              = local.common_tags
}
