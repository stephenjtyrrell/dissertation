output "network_id" {
  description = "The ID of the created VPC"
  value       = module.gcp.network_id
}

output "subnet_id" {
  description = "The ID of the created subnet"
  value       = module.gcp.subnet_id
}

output "region" {
  description = "The region where resources were deployed"
  value       = var.gcp_region
}

output "resource_prefix" {
  description = "The prefix used for resource names"
  value       = local.resource_prefix
}

output "tags" {
  description = "Common tags applied to resources"
  value       = local.common_tags
}
