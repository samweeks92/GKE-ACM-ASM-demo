/**
 * Copyright 2021 Google LLC
 */


# Create the service entries for onlineboutique
resource "null_resource" "service-entries" {

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/resources/allow-egress-googleapis.yaml"
  }

}