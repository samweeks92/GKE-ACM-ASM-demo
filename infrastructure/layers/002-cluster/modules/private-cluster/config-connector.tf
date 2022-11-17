/******************************************
  Configure Config Connector
 *****************************************/
resource "google_service_account" "config_connector_service_account" {
  count        = var.enable_config_connector ? 1 : 0
  
  project      = var.project_id
  account_id   = "config-connector"
  display_name = "Terraform-managed service account for config connector in cluster ${var.name}"
}

resource "google_project_iam_member" "config_connector_project_editor" {
  count        = var.enable_config_connector ? 1 : 0
    
  project = google_service_account.config_connector_service_account.project
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.config_connector_service_account.email}"
}

resource "google_service_account_iam_member" "config_connector_wi_user" {
  count        = var.enable_config_connector ? 1 : 0
  
  role    = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.config_connector_service_account.name
  member  = "serviceAccount:${google_service_account.config_connector_service_account.project}.svc.id.goog[cnrm-system/cnrm-controller-manager]"
}

# Create the config-connector config
resource "null_resource" "config-connector" {
  count        = var.enable_config_connector ? 1 : 0

  depends_on = [google_container_cluster.primary, null_resource.kube-creds]

  triggers = {
    always_run = timestamp()
  }
    
  provisioner "local-exec" {
    command = "sed -i -e 's/SERVICEACCOUNTPLACEHOLDER/${google_service_account.config_connector_service_account.email}/g' ${path.module}/resources/config-connector.yaml && kubectl apply -f ${path.module}/resources/config-connector.yaml"
  }

}