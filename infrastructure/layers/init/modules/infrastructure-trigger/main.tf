/**
 * Copyright 2021 Google LLC
 */


# Create Dev Cloud Build Trigger for apply
resource "google_cloudbuild_trigger" "apply" {

  name        = "infrastructure-layer-${var.layer-name}-dev-apply"
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

# Create Dev Cloud Build Trigger for destroy
resource "google_cloudbuild_trigger" "destory" {

  name        = "infrastructure-layer-${var.layer-name}-dev-destroy"
  description = "(Managed by Terraform - Do not manually edit) Infrastructure Layer ${var.layer-name} Dev Deployment"
  project     = var.project

  # trigger_template {
  #   project_id  = var.repo-project
  #   branch_name = "^master$"
  #   repo_name   = var.cloud-source-repositories-repo-name
  # }

  # included_files = ["infrastructure/layers/${var.layer-name}/**"]

  substitutions = {
    _DEPLOY_PROJECT_ = var.dev-project
    _ENVIRONMENT_    = "dev"
    _LAYER_NAME_     = var.layer-name
  }
   
  filename = var.cloudbuild-destroy-config-path

}