/**
 * Copyright 2021 Google LLC
 */


# The Google Cloud Project to create the resource in
variable "project" {
  type = string
}

variable "cicd-project" {
  type        = string
  description = "The project that contains the Cloud Source Repositories repo"
}

variable "billing-account" {
  type        = string
  description = "GCP Billing Account to use with the Projects"
}