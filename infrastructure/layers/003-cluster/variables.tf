/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
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

# GCP Region to deploy resources
variable "region" {
  type    = string
  default = "europe-west2"
}

variable "repo-name" {
  type        = string
  description = "The name of the Cloud Source Repository containing this code"
}

variable "repo-uri" {
  type        = string
  description = "The uri of the Cloud Source Repository containing this code"
}

variable "cluster_name_suffix" {
  description = "A suffix to append to the default cluster name"
  default     = ""
}

variable "release-channel" {
  type        = string
  description = "The cluster release channel to use for kubernetes and ASM"
  default = "REGULAR"
}