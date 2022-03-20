/**
 * Copyright 2021 Google LLC
 */


# Deploy onlineboutique
module "onlineboutique" {

  # Set Source
  source = "./modules/onlineboutique"

  # Set the instance of the provider
  providers = {
    kubernetes = kubernetes.primary-gke-cluster
  }

  # Define Environment Variables
  project                   = var.project
  onlineboutique-namespaces = var.onlineboutique-namespaces
 
}
