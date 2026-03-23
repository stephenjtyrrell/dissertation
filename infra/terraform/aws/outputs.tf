output "network_id" {
  description = "The ID of the created VPC"
  value       = module.aws.network_id
}

output "subnet_id" {
  description = "The ID of the created subnet"
  value       = module.aws.subnet_id
}

output "region" {
  description = "The region where resources were deployed"
  value       = var.aws_region
}

output "resource_prefix" {
  description = "The prefix used for resource names"
  value       = local.resource_prefix
}

output "tags" {
  description = "Common tags applied to resources"
  value       = local.common_tags
}
