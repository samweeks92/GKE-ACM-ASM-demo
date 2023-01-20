/**
 * Copyright 2021 Google LLC
 */



// Output the Base VPC Name
output "network" {
  value = google_compute_network.shared-vpc.name
}

// Output the VPC Subnetwork Name
output "network" {
  value = google_compute_subnetwork.subnet.name
}

// Output the CIDR range of the Pods secondary range
output "ip-range-pods" {
  value = google_compute_subnetwork.secondary_ip_range[0].ip_cidr_range
}

// Output the CIDR range of the Services secondary range
output "ip-range-services" {
  value = google_compute_subnetwork.secondary_ip_range[1].ip_cidr_range
}