/**
 * Copyright 2021 Google LLC
 */


# Create Dev Cloud Build Trigger
resource "google_cloudbuild_trigger" "dev" {

  name        = "infrastructure-layer-${var.layer-name}-dev"
  description = "(Managed by Terraform - Do not manually edit) Infrastructure Layer ${var.layer-name} Dev Deployment"
  project     = var.project

  trigger_template {
    project_id  = var.repo-project
    branch_name = "^master$"
    repo_name   = var.cloud-source-repositories-repo-name
  }

  included_files = ["infrastructure/layers/${var.layer-name}/**"]

  substitutions = {
    _DEPLOY_PROJECT_ = var.dev-project
    _ENVIRONMENT_    = "dev"
    _LAYER_NAME_     = var.layer-name
  }

  filename = var.cloudbuild-config-path

}