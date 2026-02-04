output "selected_cloud" {
  description = "The cloud provider that was deployed"
  value       = var.cloud
}

output "network_id" {
  description = "The ID of the created network/VPC/VNet"
  value = try(
    module.aws[0].network_id,
    module.azure[0].network_id,
    module.gcp[0].network_id,
    null
  )
}

output "subnet_id" {
  description = "The ID of the created subnet"
  value = try(
    module.aws[0].subnet_id,
    module.azure[0].subnet_id,
    module.gcp[0].subnet_id,
    null
  )
}

output "region" {
  description = "The region where resources were deployed"
  value = try(
    var.cloud == "aws" ? var.aws_region : null,
    var.cloud == "azure" ? var.azure_location : null,
    var.cloud == "gcp" ? var.gcp_region : null,
    null
  )
}

output "resource_prefix" {
  description = "The prefix used for resource names"
  value       = local.resource_prefix
}

output "tags" {
  description = "Common tags applied to resources"
  value       = local.common_tags
}
