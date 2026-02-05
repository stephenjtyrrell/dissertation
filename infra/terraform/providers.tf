locals {
  aws_enabled   = var.cloud == "aws"
  azure_enabled = var.cloud == "azure"
  gcp_enabled   = var.cloud == "gcp"
}

provider "aws" {
  region = var.aws_region

  skip_credentials_validation = !local.aws_enabled
  skip_requesting_account_id  = !local.aws_enabled
}

provider "azurerm" {
  features {}

  use_cli                    = local.azure_enabled
  skip_provider_registration = !local.azure_enabled
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region

  # Skip validation when not using GCP
  user_project_override = local.gcp_enabled
  request_timeout       = local.gcp_enabled ? "60s" : "1s"
}
