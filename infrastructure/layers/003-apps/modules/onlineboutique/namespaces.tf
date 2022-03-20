/**
 * Copyright 2021 Google LLC
 */


# Create the namespaces for onlineboutique
resource "kubernetes_namespace" "directus" {
  for_each = var.namespaces
  name = each.value
  metadata {
    name = "directus"
    labels = {
      "istio.io/rev" = "asm-managed"
    }
  }

}