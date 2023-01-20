/**
 * Copyright 2021 Google LLC
 */


#Get the Folder ID of the containing Folder for the CICD Project
data "google_project" "cicd-project" {
  project_id = var.cicd-project
}

data "google_folder" "folder" {
  folder              = "folders/${data.google_project.cicd-project.folder_id}"
  lookup_organization = true
}

resource "google_project" "create-project" {
  name       = var.project
  project_id = var.project
  folder_id  = data.google_project.cicd-project.folder_id
  auto_create_network = false
  billing_account = var.billing-account
}

resource "google_project_iam_member" "cb-permissions" {
  project = google_project.create-project.id
  role    = "roles/owner"
  member  = "serviceAccount:${data.google_project.cicd-project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_folder_iam_member" "cb-permissions-shared-vpc-folder" {
  
  provider = google-beta

  folder = "folders/${data.google_project.cicd-project.folder_id}"
  role    = "roles/compute.xpnAdmin"
  member  = "serviceAccount:${data.google_project.cicd-project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_organization_iam_member" "cb-permissions-shared-vpc-org" {
  
  org_id = trimprefix(data.google_folder.folder.organization, "organizations/")
  role    = "roles/compute.xpnAdmin"
  member  = "serviceAccount:${data.google_project.cicd-project.number}@cloudbuild.gserviceaccount.com"
}

# Enable Required Google APIs
resource "google_project_service" "project" {

  depends_on = [google_project_iam_member.cb-permissions]

  for_each = toset([
    "iam.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "storage.googleapis.com",
    "servicenetworking.googleapis.com",
    "servicemanagement.googleapis.com",
    "monitoring.googleapis.com",
    "iap.googleapis.com",
    "cloudbuild.googleapis.com",
    "sqladmin.googleapis.com"
  ])
  project = google_project.create-project.id
  service = each.value

  timeouts {
    create = "15m"
    update = "15m"
  }

  disable_dependent_services = false
  disable_on_destroy         = false

}

