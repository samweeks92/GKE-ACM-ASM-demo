/**
 * Copyright 2021 Google LLC
 */


# Get the remote state for layer 002-cluster
data "terraform_remote_state" "layer-002-cluster" {
  backend = "gcs"
  config = {
    bucket = "service-project-01-tfstate-mono"
    prefix = "002-cluster/${var.environment}"
  }
}