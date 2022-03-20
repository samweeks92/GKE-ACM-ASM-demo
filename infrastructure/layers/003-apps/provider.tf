/**
 * Copyright 2021 Google LLC
 */


# Define the Google Provider. Project will be passed via an TF_VAR_project
# Environment Variable which is checked by Terraform as a last resort
provider "google" {
  project = var.project
}

provider "google-beta" {
  project = var.project
}

# Retrieve an access token as the Terraform runner
data "google_client_config" "provider" {}

data "google_container_cluster" "my_cluster" {
  name     = data.terraform_remote_state.002-cluster.outputs.gke-cluster-name
  location = data.terraform_remote_state.002-cluster.outputs.gke-cluster-region
}

provider "kubernetes" {
  alias = "primary-gke-cluster"
  host  = "https://${data.google_container_cluster.my_cluster.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
  )
}