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

variable "repo-name" {
  type        = string
  description = "The name of the Cloud Source Repository containing this code"
}

# GCP Region to deploy resources
variable "region" {
  type    = string
  default = "europe-west2"
}