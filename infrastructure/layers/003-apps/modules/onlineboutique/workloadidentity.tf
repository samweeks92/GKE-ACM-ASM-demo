resource "google_service_account_iam_binding" "workload-identity-binding" {
  for_each = var.onlineboutique-namespaces
  
  service_account_id = "projects/${var.project}/serviceAccounts/${var.cluster-sa}
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project}.svc.id.goog[${each.value}/${each.value}]",
  ]
}