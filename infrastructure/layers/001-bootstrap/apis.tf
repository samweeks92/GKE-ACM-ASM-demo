/**
 * Copyright 2021 Google LLC
 */


# Enable Required Google APIs
resource "google_project_service" "project" {

  for_each = toset([
    "iam.googleapis.com",
    "compute.googleapis.com",
    "run.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "cloudfunctions.googleapis.com",
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "dataflow.googleapis.com",
    "servicenetworking.googleapis.com",
    "servicemanagement.googleapis.com",
    "secretmanager.googleapis.com",
    "sql-component.googleapis.com",
    "redis.googleapis.com",
    "pubsub.googleapis.com",
    "monitoring.googleapis.com",
    "iap.googleapis.com",
    "earthengine.googleapis.com",
    "dns.googleapis.com",
    "bigquerystorage.googleapis.com",
    "cloudscheduler.googleapis.com",
    "cloudbuild.googleapis.com",
    "sqladmin.googleapis.com"
  ])
  project = var.project
  service = each.value

  timeouts {
    create = "15m"
    update = "15m"
  }

  disable_dependent_services = false
  disable_on_destroy         = false

}


