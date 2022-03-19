/**
 * Copyright 2021 Google LLC
 */


# GCP Project to deploy resources
variable "project" {
  type = string
}

# GCP Region to deploy resources
variable "region" {
  type    = string
  default = "europe-west2"
}
