/**
 * Copyright 2021 Google LLC
 */


# Grant Googlers Editor on Dev Project
resource "google_project_iam_member" "dev-sustainability-eng-editor" {

  count = var.project == "fsus-dev" ? 1 : 0

  project = var.project
  role    = "roles/editor"
  member  = "user:weekss@google.com"

}