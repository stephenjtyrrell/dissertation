locals {
  aws_enabled   = var.cloud == "aws"
  azure_enabled = var.cloud == "azure"
  gcp_enabled   = var.cloud == "gcp"
}

provider "aws" {
  region = var.aws_region

  access_key                  = local.aws_enabled ? null : "unused"
  secret_key                  = local.aws_enabled ? null : "unused"
  skip_credentials_validation = !local.aws_enabled
  skip_requesting_account_id  = !local.aws_enabled
}

provider "azurerm" {
  features {}

  use_cli                    = local.azure_enabled
  subscription_id            = local.azure_enabled ? null : "00000000-0000-0000-0000-000000000000"
  tenant_id                  = local.azure_enabled ? null : "00000000-0000-0000-0000-000000000000"
  client_id                  = local.azure_enabled ? null : "00000000-0000-0000-0000-000000000000"
  client_secret              = local.azure_enabled ? null : "unused"
  skip_provider_registration = !local.azure_enabled
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region

  access_token = local.gcp_enabled ? null : "unused"
}
