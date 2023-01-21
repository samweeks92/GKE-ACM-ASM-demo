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
 
resource "google_gke_hub_feature" "configmanagement_acm_feature" {
  count    = var.enable_acm_feature ? 1 : 0
  name     = "configmanagement"
  project  = var.service-project
  location = "global"
  provider = google-beta

  depends_on = [google_gke_hub_membership.membership]
}

resource "google_gke_hub_feature_membership" "feature_member" {
  provider   = google-beta
  location   = "global"
  project    = var.service-project
  feature    = google_gke_hub_feature.configmanagement_acm_feature[0].name
  membership = google_gke_hub_membership.membership[0].membership_id
  configmanagement {
    version = "1.13.1"
 
    config_sync {
      source_format = "unstructured"
      git {
        gcp_service_account_email = var.service-account-email
        sync_repo   = var.sync_repo
        policy_dir = var.policy_dir
        secret_type = var.secret_type
        sync_branch = var.sync_branch
        sync_wait_secs = "5"
      }
    }
    policy_controller {
      enabled                    = true
      template_library_installed = true
      referential_rules_enabled  = true
    }
  }
}

resource "google_project_iam_member" "config_sync_project_editor-service" {    
  project = var.service-project
  role    = "roles/editor"
  member  = "serviceAccount:${var.service-account-email}"
}

resource "google_project_iam_member" "config_connector_project_editor-cicd" {
  project = var.cicd-project
  role    = "roles/editor"
  member  = "serviceAccount:${var.service-account-email}"
}

resource "google_service_account_iam_member" "config_connector_wi_user" {
  role    = "roles/iam.workloadIdentityUser"
  service_account_id = var.service-account-name
  member  = "serviceAccount:${var.service-project}.svc.id.goog[cnrm-system/cnrm-controller-manager]"
}