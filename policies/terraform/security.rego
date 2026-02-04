package terraform

required_tags := {"owner", "cost_center", "compliance", "project", "environment", "managed_by"}

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
  after := rc.change.after
  
  # Look for a corresponding flow log resource
  # vpc_id in flow log can be either a direct reference like "aws_vpc.example.id" 
  # or an actual VPC ID. We check if the flow log's vpc_id contains the VPC resource address.
  flow_log_exists := [log | 
    some log in input.resource_changes
    log.type == "aws_flow_log"
    vpc_id := log.change.after.vpc_id
    # Check if vpc_id references this VPC (e.g., "aws_vpc.example.id" contains "aws_vpc.example")
    startswith(vpc_id, concat("", [rc.address, "."]))
  ]
  count(flow_log_exists) == 0
  msg := sprintf("%s should have VPC Flow Logs enabled", [rc.address])
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
  "0.0.0.0/0" in after.source_ranges
  "allow" in after.direction
  msg := sprintf("%s should not allow unrestricted ingress from 0.0.0.0/0", [rc.address])
}
