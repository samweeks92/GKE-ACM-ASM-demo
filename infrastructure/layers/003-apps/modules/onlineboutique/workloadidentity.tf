resource "google_service_account_iam_binding" "workload-identity-binding" {
  
  service_account_id = "projects/${var.project}/serviceAccounts/${var.cluster-sa}"
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project}.svc.id.goog[ad/ad]",
    "serviceAccount:${var.project}.svc.id.goog[cart/cart]",
    "serviceAccount:${var.project}.svc.id.goog[checkout/checkout]",
    "serviceAccount:${var.project}.svc.id.goog[currency/currency]",
    "serviceAccount:${var.project}.svc.id.goog[email/email]",
    "serviceAccount:${var.project}.svc.id.goog[frontend/frontend]",
    "serviceAccount:${var.project}.svc.id.goog[loadgenerator/loadgenerator]",
    "serviceAccount:${var.project}.svc.id.goog[payment/payment]",
    "serviceAccount:${var.project}.svc.id.goog[product-catalog/product-catalog]",
    "serviceAccount:${var.project}.svc.id.goog[recommendation/recommendation]",
    "serviceAccount:${var.project}.svc.id.goog[shipping/shipping]"
  ]
}