/**
 * Copyright 2021 Google LLC
 */


# The Google Cloud Project to create the resource in
variable "project" {
  type = string
}

variable "istogateway-namespace" {
  description = "namespace required for istio gateways"
  type        = string
}