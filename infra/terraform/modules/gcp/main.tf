resource "google_compute_network" "this" {
  name                    = "${var.name_prefix}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  name          = "${var.name_prefix}-subnet"
  ip_cidr_range = var.subnet_cidr_block
  region        = var.region
  network       = google_compute_network.this.id
}

# Note: GCP networks don't support labels directly
# Labels are applied at the project or resource level for supported resources

output "network_id" {
  value = google_compute_network.this.id
}

output "subnet_id" {
  value = google_compute_subnetwork.this.id
}
