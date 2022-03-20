/**
 * Copyright 2021 Google LLC
 */


variable "repo-project" {
  type        = string
  description = "The project that contains the Cloud Source Repositories repo"
}

variable "cloud-source-repositories-repo-name" {
  type        = string
  description = "The name of the Cloud Source Repository containing this code"
}

variable "cloud-source-repositories-repo-uri" {
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

variable "cloudbuild-destroy-config-path" {
  type        = string
  description = "The name of the cloudbuild.yaml used for deploying the infrastructure layer"
  default     = "build/config/infrastructure/global/cloudbuild-destroy.yaml"
}

variable "dev-project" {
  type        = string
  description = "The name of the dev project for GFIE"
}

variable "project" {
  type        = string
  description = "The Google Cloud Project to create the resource in"
}