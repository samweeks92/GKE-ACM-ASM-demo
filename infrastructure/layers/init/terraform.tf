/**
 * Copyright 2021 Google LLC
 */


# Define Terraform Backend Remote State
terraform {
  backend "gcs" {
    bucket = "service-project-01-init-state"
  }
}