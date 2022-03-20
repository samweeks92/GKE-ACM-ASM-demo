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

# GCP Environment to deploy resources
variable "environment" {
  type = string
}

variable "namespaces" {
  description = "list of namespaces required for onlineboutique"
  type        = set(string)
  default     = ["ad", "cart", "checkout", "currency", "email", "frontend", "loadgenerator", "payment", "product-catalog", "recommendation", "shipping"]
}
