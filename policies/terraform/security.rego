package terraform

required_tags := {"owner", "cost_center", "compliance", "project", "environment", "managed_by"}

deny contains msg if {
  some rc in input.resource_changes
  rc.type in {"aws_s3_bucket", "azurerm_storage_account", "google_storage_bucket"}
  after := rc.change.after
  after.public_access != null
  after.public_access == true
  msg := sprintf("%s must not allow public access", [rc.address])
}

deny contains msg if {
  some rc in input.resource_changes
  # Terraform plan may expose metadata in tags (AWS/Azure) or labels (GCP)
  tags := object.get(rc.change.after, "tags", object.get(rc.change.after, "labels", {}))
  missing := required_tags - object.keys(tags)
  count(missing) > 0
  msg := sprintf("%s is missing required metadata: %v", [rc.address, missing])
}
