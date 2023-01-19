/**
 * Copyright 2021 Google LLC
 */


variable "cicd-project" {
  type        = string
  description = "GCP Project to run the deployment pipelines from"
}

variable "host-project" {
  type        = string
  description = "The name of the host project to create"
}

variable "service-project" {
  type        = string
  description = "The name of the service project to create"
}

variable "billing-account" {
  type        = string
  description = "GCP Billing Account to use with the Projects"
}

# Name of the GCS Bucket that stores the init TF state
variable "state-bucket" {
  type = string
}

# GCP Region to deploy resources
variable "region" {
  type    = string
  default = "europe-west2"
}