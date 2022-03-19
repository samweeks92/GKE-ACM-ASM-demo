/**
 * Copyright 2021 Google LLC
 */


variable "project" {
  type        = string
  description = "GCP Project to deploy resources"
}

variable "dev-project" {
  type        = string
  description = "The name of the dev project for GFIE"
}

variable "region" {
  type        = string
  default     = "europe-west2"
  description = "GCP Region to deploy resources"
}

variable "repo-project" {
  type        = string
  description = "The project that contains the Cloud Source Repositories repo"
}

variable "cloud-source-repositories-repo-name" {
  type        = string
  description = "The name of the Cloud Source Repository containing this code"
}