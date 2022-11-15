/**
 * Copyright 2018 Google LLC
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

locals {
  cluster_type = "simple-zonal-asm"
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

data "google_project" "project" {
  project_id = var.project
}

data "google_compute_subnetwork" "subnetwork" {
  name    = var.subnetwork
  project = var.host_project
  region  = var.region
}

module "gke" {
  source                  = "./modules/private-cluster/"
  project_id              = var.project
  project_number          = data.google_project.project.number
  name                    = "${local.cluster_type}-cluster${var.cluster_name_suffix}"
  regional                = false
  region                  = var.region
  release_channel         = var.release_channel
  zones                   = var.zones
  network                 = var.network
  subnetwork              = var.subnetwork
  ip_range_pods           = var.ip_range_pods
  ip_range_services       = var.ip_range_services
  create_service_account  = true
  enable_private_endpoint = false
  enable_private_nodes    = true
  master_ipv4_cidr_block  = "172.16.0.0/28"

  master_authorized_networks = [
    {
      cidr_block   = data.google_compute_subnetwork.subnetwork.ip_cidr_range
      display_name = "VPC"
    },
    {
      cidr_block   = "34.134.135.100/32"
      display_name = "CloudShell"
    },
        {
      cidr_block   = "10.100.0.0/14"
      display_name = "pods"
    },
        {
      cidr_block   = "10.110.0.0/20"
      display_name = "services"
    },
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "all"
    }
  ]
}

module "asm" {
  source                    = "./modules/asm"
  project_id                = var.project
  cluster_name              = module.gke.name
  cluster_location          = module.gke.location
  cluster_id                = module.gke.cluster_id
  multicluster_mode         = "connected"
  enable_cni                = true
  enable_fleet_registration = true
  enable_mesh_feature       = true
  enable_acm_feature        = true
}








