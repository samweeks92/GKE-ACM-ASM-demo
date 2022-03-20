/**
 * Copyright 2021 Google LLC
 */


# Deploy istio-gateways
module "istio-gateways" {

  # Set Source
  source = "./modules/istio-gateways"

  # Set the instance of the provider
  providers = {
    kubernetes = kubernetes.primary-gke-cluster
  }

  # Define Environment Variables
  project                         = var.project
  istogateway-namespace          = var.istogateway-namespace

}
