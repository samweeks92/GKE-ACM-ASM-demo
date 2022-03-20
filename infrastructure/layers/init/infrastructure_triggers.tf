/**
 * Copyright 2021 Google LLC
 */


# Create Triggers for Infrastructure Deployment layer-001-bootstrap
module "infrastructure-triggers-layer-001-bootstrap" {

  # Set Source
  source = "./modules/infrastructure-trigger"

  # Define Variables
  project                             = var.project
  repo-project                        = var.project
  cloud-source-repositories-repo-name = var.cloud-source-repositories-repo-name
  layer-name                          = "001-bootstrap"
  dev-project                         = var.dev-project
  cloud-source-repositories-repo-uri  = var.cloud-source-repositories-repo-uri

}

# Create a Triggers for Infrastructure Deployment layer-002-cluster
module "infrastructure-triggers-layer-002-cluster" {

  # Set Source
  source = "./modules/infrastructure-trigger"

  # Define Variables
  project                             = var.project
  repo-project                        = var.project
  cloud-source-repositories-repo-name = var.cloud-source-repositories-repo-name
  cloud-source-repositories-repo-uri  = var.cloud-source-repositories-repo-uri
  layer-name                          = "002-cluster"
  dev-project                         = var.dev-project

}

# Create a Triggers for Infrastructure Deployment layer-003-onlineboutique
module "infrastructure-triggers-layer-003-onlineboutique" {

  # Set Source
  source = "./modules/infrastructure-trigger"

  # Define Variables
  project                             = var.project
  repo-project                        = var.project
  cloud-source-repositories-repo-name = var.cloud-source-repositories-repo-name
  cloud-source-repositories-repo-uri  = var.cloud-source-repositories-repo-uri
  layer-name                          = "003-onlineboutique"
  dev-project                         = var.dev-project

}