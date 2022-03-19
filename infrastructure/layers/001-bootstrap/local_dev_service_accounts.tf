/**
 * Copyright 2021 Google LLC
 */


# Create a Local Dev Service Accounts for Googlers
# NB: Check local_dev_service_accounts_iam.tf if removing users
module "local-dev-service-account-googlers" {

  # Only apply module if in the dev environment
  count = var.project == "service-project-01-tfstate-mono" ? 1 : 0

  # Set Source
  source = "./modules/local-dev-service-account"

  # Define Environment Variables
  developers = {
    weekss = {
      name                 = "Sam Weeks"
      google-account-email = "weekss@google.com"
    }
  }
  project = var.project

}