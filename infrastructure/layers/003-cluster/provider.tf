/**
 * Copyright 2021 Google LLC
 */


# Define the Google Provider. Project will be passed via an TF_VAR_project
# Environment Variable which is checked by Terraform as a last resort
provider "google" {
  project = var.service-project
}

provider "google-beta" {
  project = var.service-project
}