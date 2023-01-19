/**
 * Copyright 2021 Google LLC
 */

# Create a GCS Bucket for storing state for the intermediate layers (NB: This does not store state for the init layer)
resource "google_storage_bucket" "terraform-state" {

  name     = "${var.cicd-project}-tfstate-mono"
  location = "US"

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

}