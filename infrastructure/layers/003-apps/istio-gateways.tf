/**
 * Copyright 2021 Google LLC
 */


# Deploy istio-gateways
module "istio-gateways" {

  # Set Source
  source = "./modules/istio-gateways"

  # Set the instance of the provider
  providers = {
    # kubernetes.my-cluster = kubernetes.primary-gke-cluster
    kubernetes = kubernetes.primary-gke-cluster    
  }

  # Define Environment Variables
  project                         = var.project
  istiogateway-namespace          = var.istiogateway-namespace

}
