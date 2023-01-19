/**
 * Copyright 2021 Google LLC
 */


# Create Dev Cloud Build Trigger for apply
resource "google_cloudbuild_trigger" "apply" {

  name        = "infrastructure-layer-${var.layer-name}-apply"
  description = "(Managed by Terraform - Do not manually edit) Infrastructure Layer ${var.layer-name} Dev Deployment"
  project     = var.cicd-project

  trigger_template {
    project_id  = var.cicd-project
    branch_name = "^master$"
    repo_name   = var.repo-name
  }

  included_files = ["infrastructure/layers/${var.layer-name}/**"]

  substitutions = {
    _CICD_PROJECT_ = var.cicd-project
    _HOST_PROJECT_ = var.host-project
    _SERVICE_PROJECT_ = var.service-project
    _BILLING_ACCOUNT_ = var.billing-account
    _LAYER_NAME_     = var.layer-name
  }
   
  filename = var.cloudbuild-config-path 

}