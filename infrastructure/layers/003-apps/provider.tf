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

provider "kubernetes" {
  alias = "primary-gke-cluster"
  host = "https://${data.terraform_remote_state.layer-002-cluster.outputs.kubernetes_endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.layer-002-cluster.outputs.ca_certificate
  )
}