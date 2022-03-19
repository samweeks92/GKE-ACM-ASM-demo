/**
 * Copyright 2021 Google LLC
 */


# Create the Service Account(s) defined in var.developers
resource "google_service_account" "local-dev-service-account" {

  for_each     = var.developers
  account_id   = each.key
  display_name = "${each.value.name} LOCAL DEV"
  description  = "Local Development Service Account for ${each.value.name}"

}


# Grant the user permission to download the Service Account Key for the Service Account
resource "google_service_account_iam_member" "local-dev-service-account-key-admin" {

  for_each           = var.developers
  service_account_id = google_service_account.local-dev-service-account[each.key].name
  role               = "roles/iam.serviceAccountKeyAdmin"
  member             = "user:${each.value.google-account-email}"

}

# Grant IAP Access
resource "google_iap_web_iam_member" "bynd-local-dev-iap-access" {

  for_each = var.developers
  project  = var.project
  role     = "roles/iap.httpsResourceAccessor"
  member   = "serviceAccount:${google_service_account.local-dev-service-account[each.key].email}"

}