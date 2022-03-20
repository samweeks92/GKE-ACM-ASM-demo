/**
 * Copyright 2021 Google LLC
 */


# The Google Cloud Project to create the resource in
variable "project" {
  type = string
}

variable "onlineboutique-namespaces" {
  description = "list of namespaces required for onlineboutique"
  type        = set(string)
}