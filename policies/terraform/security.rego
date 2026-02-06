package terraform

required_tags := {"owner", "cost_center", "compliance", "project", "environment", "managed_by"}

# Resource types that do not support tags/labels
untaggable_resource_types := {
  "aws_iam_role_policy",
  "aws_iam_policy_attachment",
  "aws_route_table_association",
  "aws_security_group_rule",
  "azurerm_subnet",
  "google_compute_network",
  "google_compute_subnetwork",
}

# Check for public access on storage resources
deny contains msg if {
  some rc in input.resource_changes
  rc.type in {"aws_s3_bucket", "azurerm_storage_account", "google_storage_bucket"}
  after := rc.change.after
  after.public_access != null
  after.public_access == true
  msg := sprintf("%s must not allow public access", [rc.address])
}

# Check for required tags/labels on all resources
deny contains msg if {
  some rc in input.resource_changes
  rc.mode == "managed"
  rc.change.actions[_] != "delete"
  not rc.type in untaggable_resource_types
  
  # Get tags or labels from the resource
  after := rc.change.after
  tags := object.get(after, "tags", object.get(after, "labels", {}))
  
  # Check for missing required tags
  missing := required_tags - object.keys(tags)
  count(missing) > 0
  msg := sprintf("%s is missing required metadata: %v", [rc.address, missing])
}

# Ensure encryption is enabled for storage
deny contains msg if {
  some rc in input.resource_changes
  rc.type == "aws_s3_bucket"
  after := rc.change.after
  not after.server_side_encryption_configuration
  msg := sprintf("%s must have server-side encryption enabled", [rc.address])
}

# Check VPC flow logs are enabled
deny contains msg if {
  some rc in input.resource_changes
  rc.type == "aws_vpc"
  rc.change.actions[_] != "delete"
  vpc_address := rc.address
  
  # Look for a corresponding flow log resource in the plan
  flow_log_exists := [log | 
    some log in input.resource_changes
    log.type == "aws_flow_log"
    log.change.actions[_] != "delete"
  ]
  count(flow_log_exists) == 0
  msg := sprintf("%s should have VPC Flow Logs enabled", [vpc_address])
}

# Ensure Azure storage uses HTTPS only
deny contains msg if {
  some rc in input.resource_changes
  rc.type == "azurerm_storage_account"
  after := rc.change.after
  after.enable_https_traffic_only == false
  msg := sprintf("%s must enable HTTPS traffic only", [rc.address])
}

# Check for default network exposure in GCP
deny contains msg if {
  some rc in input.resource_changes
  rc.type == "google_compute_firewall"
  after := rc.change.after
  
  # Check if source_ranges includes 0.0.0.0/0
  "0.0.0.0/0" in after.source_ranges
  
  # Check if direction is INGRESS (or not set, which defaults to INGRESS)
  direction := object.get(after, "direction", "INGRESS")
  direction == "INGRESS"
  
  # Check if there are any allow rules
  allow_rules := object.get(after, "allow", [])
  count(allow_rules) > 0
  
  msg := sprintf("%s should not allow unrestricted ingress from 0.0.0.0/0", [rc.address])
}
