/**
 * Copyright 2021 Google LLC
 */


# Create the namespaces for onlineboutique
resource "kubernetes_namespace" "directus" {
  for_each = var.onlineboutique-namespaces
  metadata {
    name = each.value
    labels = {
      "istio.io/rev" = "asm-managed"
    }
  }

}