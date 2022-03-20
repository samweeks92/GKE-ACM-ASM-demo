/**
 * Copyright 2021 Google LLC
 */


# Create the namespaces for onlineboutique
resource "kubernetes_namespace" "gateways" {

  metadata {
    name = var.istiogateway-namespace
    labels = {
      "istio.io/rev" = "asm-managed"
    }
  }

}