output "selected_cloud" {
  value = var.cloud
}

output "network_id" {
  value = try(
    module.aws[0].network_id,
    module.azure[0].network_id,
    module.gcp[0].network_id,
    null
  )
}

output "subnet_id" {
  value = try(
    module.aws[0].subnet_id,
    module.azure[0].subnet_id,
    module.gcp[0].subnet_id,
    null
  )
}
