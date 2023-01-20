/**
 * Copyright 2021 Google LLC
 */


variable "cicd-project" {
  type        = string
  description = "The project that contains the Cloud Source Repositories repo"
}

variable "host-project" {
  type        = string
  description = "The name of the Host Project to create"
}

variable "service-project" {
  type        = string
  description = "The name of the Service Project to create"
}

variable "billing-account" {
  type        = string
  description = "GCP Billing Account to use with the Projects"
}

variable "repo-name" {
  type        = string
  description = "The name of the Cloud Source Repository containing this code"
}

variable "repo-uri" {
  type        = string
  description = "The uri of the Cloud Source Repository containing this code"
}

variable "layer-name" {
  type        = string
  description = "The name of the infrastructure layer being deployed"
}

variable "cloudbuild-config-path" {
  type        = string
  description = "The name of the cloudbuild.yaml used for deploying the infrastructure layer"
  default     = "build/config/infrastructure/global/cloudbuild.yaml"
}