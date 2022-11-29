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

# # resource "kubernetes_namespace" "system" {
# #   metadata {
# #     name = "istio-system"
# #   }
# # }

resource "google_gke_hub_feature" "mesh" {
  count    = var.enable_mesh_feature ? 1 : 0
  name     = "servicemesh"
  project  = var.project_id
  location = "global"
  provider = google-beta

  depends_on = [google_gke_hub_membership.membership]
}

resource "google_gke_hub_feature_membership" "feature_member_mesh" {
  location = "global"
  feature = google_gke_hub_feature.mesh[0].name
  membership = google_gke_hub_membership.membership[0].membership_id
  mesh {
    management = "MANAGEMENT_AUTOMATIC"
  }
  provider = google-beta
}