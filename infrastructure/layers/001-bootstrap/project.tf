/**
 * Copyright 2021 Google LLC
 */


# Create a Local Dev Service Accounts for Googlers
# NB: Check local_dev_service_accounts_iam.tf if removing users
module "create-host-project" {

  # Set Source
  source = "./modules/create-projects"

  # Define Environment Variables
  project = var.host-project
  cicd-project = var.cicd-project
  billing-account = var.billing-account

}

module "create-service-project" {

  # Set Source
  source = "./modules/create-projects"

  # Define Environment Variables
  project = var.service-project
  cicd-project = var.cicd-project
  billing-account = var.billing-account

}