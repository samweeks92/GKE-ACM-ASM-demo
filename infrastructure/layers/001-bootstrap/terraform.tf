/**
 * Copyright 2021 Google LLC
 */


# Define Terraform Backend Remote State
terraform {
  backend "gcs" {
    bucket = "shared-infra-cicd-tfstate-mono"
  }
}