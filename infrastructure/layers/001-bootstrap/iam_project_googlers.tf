/**
 * Copyright 2021 Google LLC
 */


# Grant Googlers Editor on Dev Project
resource "google_project_iam_member" "eng-editor" {

  count = var.project == "serviceproject01-svpc-01" ? 1 : 0

  project = var.project
  role    = "roles/editor"
  member  = "user:weekss@google.com"

}