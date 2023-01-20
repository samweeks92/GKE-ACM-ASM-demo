/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "google_compute_network" "shared-vpc" {
  name                            = "shared-vpc"
  auto_create_subnetworks         = false
  routing_mode                    = "GLOBAL"
  project                         = var.host-project
  description                     = "Shared VPC used for GKE cluster"
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "subnet" {
  name            = "cluster-subnet"
  project         = var.host-project
  network         = google_compute_network.shared-vpc.id
  region          = "europe-west2"
  ip_cidr_range   = "10.0.4.0/22"
  
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.100.0.0/14"
  }
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.110.0.0/20"
  }
}

resource "google_compute_global_address" "private_services_access" {
  name          = "${var.host-project}-psa"
  project       = var.host-project
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.shared-vpc.id
}

resource "google_service_networking_connection" "private_services_access" {
  network                 = google_compute_network.shared-vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_services_access.name]
}

resource "google_compute_router" "router" {
  name    = "shared-vpc-router"
  region  = var.region
  project         = var.host-project
  network = google_compute_network.shared-vpc.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "shared-vpc-nat"
  project                            = var.host-project
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_shared_vpc_host_project" "host" {

  provider = google-beta

  project = var.host-project
  depends_on = [google_compute_network.shared-vpc]
}

resource "google_compute_shared_vpc_service_project" "service-project" {
  host_project    = google_compute_shared_vpc_host_project.host.project
  service_project = var.service-project
}

#Get the Folder ID of the containing Folder for the Service Project
data "google_project" "service-project" {
  project_id = var.service-project
}

resource "google_compute_subnetwork_iam_member" "google-apis" {
  project = var.host-project
  region = var.region
  subnetwork = google_compute_subnetwork.subnet.name
  role = "roles/compute.networkUser"
  member = "serviceAccount:${data.google_project.service_project.number}@cloudservices.gserviceaccount.com"
}

resource "google_compute_subnetwork_iam_member" "gke" {
  project = var.host-project
  region = var.region
  subnetwork = google_compute_subnetwork.subnet.name
  role = "roles/compute.networkUser"
  member = "serviceAccount:service-${data.google_project.service_project.number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "host-project-security-admin" {
  project = var.host-project
  role    = "roles/compute.securityAdmin"
  member  = "serviceAccount:service-${data.google_project.service_project.number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "host-project-container-service-agent-user" {
  project = var.host-project
  role    = "roles/container.hostServiceAgentUser"
  member  = "serviceAccount:service-${data.google_project.service_project.number}@container-engine-robot.iam.gserviceaccount.com"
}