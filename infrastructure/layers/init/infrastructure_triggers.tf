/**
 * Copyright 2021 Google LLC
 */


# Create Triggers for Infrastructure Deployment layer-001-bootstrap
module "infrastructure-triggers-layer-001-bootstrap" {

  # Set Source
  source = "./modules/infrastructure-trigger"

  # Define Variables
  cicd-project                        = var.cicd-project
  host-project                        = var.host-project
  service-project                     = var.service-project
  billing-account                     = var.billing-account
  cloud-source-repositories-repo-name = var.repo-name
  cloud-source-repositories-repo-uri  = "https://source.cloud.google.com/${var.cicd-project}/${var.repo-name}"
  layer-name                          = "001-bootstrap"

}

# Create a Triggers for Infrastructure Deployment layer-002-networking
module "infrastructure-triggers-layer-002-networking" {

  # Set Source
  source = "./modules/infrastructure-trigger"

  # Define Variables
  cicd-project                        = var.cicd-project
  host-project                        = var.host-project
  service-project                     = var.service-project
  billing-account                     = var.billing-account
  cloud-source-repositories-repo-name = var.repo-name
  cloud-source-repositories-repo-uri  = "https://source.cloud.google.com/${var.cicd-project}/${var.repo-name}"
  layer-name                          = "002-networking"

}

# Create a Triggers for Infrastructure Deployment layer-003-cluster
module "infrastructure-triggers-layer-003-cluster" {

  # Set Source
  source = "./modules/infrastructure-trigger"

  # Define Variables
  cicd-project                        = var.cicd-project
  host-project                        = var.host-project
  service-project                     = var.service-project
  billing-account                     = var.billing-account
  cloud-source-repositories-repo-name = var.repo-name
  cloud-source-repositories-repo-uri  = "https://source.cloud.google.com/${var.cicd-project}/${var.repo-name}"
  layer-name                          = "003-cluster"

}