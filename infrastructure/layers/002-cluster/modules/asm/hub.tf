/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "google_gke_hub_membership" "membership" {
  count         = var.enable_fleet_registration ? 1 : 0
  provider      = google-beta
  project       = var.project_id
  membership_id = "${var.cluster_name}-membership"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${var.cluster_id}"
    }
  }
}

resource "google_gke_hub_feature" "mesh" {
  count    = var.enable_mesh_feature ? 1 : 0
  name     = "servicemesh"
  project  = var.project_id
  location = "global"
  provider = google-beta
}

# Run this local-exec on every single run to configure the fleet membership for managed ASM
resource "null_resource" "managed-asm-control-plane" {

  depends_on = [google_gke_hub_feature.mesh]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${var.cluster_name} --region=${var.cluster_location} --project=${var.project_id} && gcloud container fleet mesh update --control-plane automatic --memberships ${var.cluster_name}-membership --project ${var.project_id}"
  }

}