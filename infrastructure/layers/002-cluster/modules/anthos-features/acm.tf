# resource "google_gke_hub_feature" "configmanagement_acm_feature" {
#   count    = var.enable_acm_feature ? 1 : 0
#   name     = "configmanagement"
#   project  = var.project_id
#   location = "global"
#   provider = google-beta

#     depends_on = [google_gke_hub_membership.membership]
# }
 
 
# resource "google_gke_hub_feature_membership" "feature_member" {
#   provider   = google-beta
#   location   = "global"
#   feature    = "configmanagement"
#   membership = google_gke_hub_membership.membership[0].membership_id
#   configmanagement {
#     version = "1.13.1"
 
#     config_sync {
#       source_format = "unstructured"
#       git {
#         sync_repo   = var.sync_repo
#         policy_dir = var.policy_dir
#         secret_type = var.secret_type
#         sync_branch = var.sync_branch
#       }
#     }
#     policy_controller {
#       enabled                    = true
#       template_library_installed = true
#       referential_rules_enabled  = true
#     }
#   }

# }