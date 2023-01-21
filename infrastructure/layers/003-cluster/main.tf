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

# Configure the remote state for layer 003-networking to get data on the networking for hte project
data "terraform_remote_state" "layer-002-networking" {
  backend = "gcs"
  config = {
    bucket = "shared-infra-cicd-tfstate-mono"
    prefix = "002-networking"
  }
}

locals {
  cluster_type = "private-regional-asm-acm"
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

data "google_project" "service-project" {
  project_id = var.service-project
}

data "google_compute_subnetwork" "subnetwork" {
  name    = data.terraform_remote_state.layer-002-networking.outputs.subnetwork
  project = var.host-project
  region  = var.region
}

module "gke" {
  source                  = "./modules/private-cluster/"
  project_id              = var.service-project
  project_number          = data.google_project.service-project.number
  host-project            = var.host-project
  name                    = "${local.cluster_type}-cluster${var.cluster_name_suffix}"
  regional                = true
  region                  = var.region
  release_channel         = var.release-channel
  zones                   = ["${var.region}-a","${var.region}-b","${var.region}-c"]
  network                 = data.terraform_remote_state.layer-002-networking.outputs.network
  subnetwork              = data.terraform_remote_state.layer-002-networking.outputs.subnetwork
  ip_range_pods           = data.terraform_remote_state.layer-002-networking.outputs.ip-range-pods-name
  ip_range_services       = data.terraform_remote_state.layer-002-networking.outputs.ip-range-services-name
  create_service_account  = true
  enable_private_endpoint = false
  enable_private_nodes    = true
  enable_config_connector = true
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
      cidr_block   = data.terraform_remote_state.layer-002-networking.outputs.ip-range-pods
      display_name = "pods"
    },
        {
      cidr_block   = data.terraform_remote_state.layer-002-networking.outputs.ip-range-services
      display_name = "services"
    },
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "all"
    }
  ]
}

module "anthos-features" {
  source                    = "./modules/anthos-features"
  service-project           = var.service-project
  cluster_name              = module.gke.name
  cluster_location          = module.gke.location
  cluster_id                = module.gke.cluster_id
  multicluster_mode         = "connected"
  enable_cni                = false
  enable_fleet_registration = true
  enable_mesh_feature       = true
  enable_acm_feature        = true
  sync_repo                 = "https://source.cloud.google.com/${var.cicd-project}/${var.repo-name}"
  policy_dir                = "apps/root-sync/init"
  secret_type               = "none"
  sync_branch               = "master"
}






