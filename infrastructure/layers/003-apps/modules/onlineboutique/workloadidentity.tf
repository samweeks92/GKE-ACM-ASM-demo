resource "google_service_account_iam_member" "workload-identity-binding" {
  for_each = var.onlineboutique-namespaces
  
  service_account_id = "projects/${var.project}/serviceAccounts/${var.cluster-sa}"
  role               = "roles/iam.workloadIdentityUser"

  member = "serviceAccount:${var.project}.svc.id.goog[${each.value}/${each.value}]"
}