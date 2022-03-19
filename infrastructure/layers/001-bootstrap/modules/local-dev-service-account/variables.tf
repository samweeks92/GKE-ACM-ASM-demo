/**
 * Copyright 2021 Google LLC
 */


# Map of developers who require a Local Dev Service Account
variable "developers" {
  type = map(any)
}

# The Google Cloud Project to create the resource in
variable "project" {
  type = string
}