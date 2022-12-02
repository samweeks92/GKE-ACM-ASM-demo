
# existing variables

# variable "network" {
#   description = "The VPC network to host the cluster in"
# }

variable "cluster-subnetwork" {
  description = "The subnetwork to host the cluster in"
  default = "shared-vpc"
}

variable "proxy-only-subnetwork" {
  description = "The subnetwork for the proxy-only subnetwork"
  default = "proxy-only-subnet"
}

variable "region" {
  description = "The region to host the cluster in"
}

variable "neg-service-name" {
  description = "the name of the NEG backend service"
  default = "k8s1-ae2f7d80-hello-hello-app-cluster-ip-neg-v3-80-34a7580a"
}



#
# MY PRODUCER ENVIRONMENT IS A GKE CLUSTER IN A SHARED VPC, SO THE NETWORK AND SUBNETWORK OF THE CLUSTER AS WELL AS THE PROXY-ONLY SUBNET HAVE ALREADY BEEN CREATED IN MY HOST PROEJCT AND HAVE BEEN SHARED TO MY SERVICE PROJECT WHERE MY CLUSTER RUNS
#

# # VPC network
# resource "google_compute_network" "default" {
#   name                    = "l7-ilb-network"
#   auto_create_subnetworks = false
# }

# # Proxy-only subnet
# resource "google_compute_subnetwork" "proxy_subnet" {
#   name          = "l7-ilb-proxy-subnet"
#   ip_cidr_range = "10.0.0.0/24"
#   region        = var.region
#   purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
#   role          = "ACTIVE"
#   network       = var.network
# }

# Backend subnet
# resource "google_compute_subnetwork" "default" {
#   name          = "l7-ilb-subnet"
#   ip_cidr_range = "10.0.1.0/24"
#   region        = "europe-west1"
#   network       = google_compute_network.default.id
# }

# Reserved internal address
resource "google_compute_address" "default" {
  name         = "l7-ilb-ip"
  provider     = google-beta
  subnetwork   = var.subnetwork
  address_type = "INTERNAL"
  address      = "10.0.1.5"
  region       = var.region
  purpose      = "SHARED_LOADBALANCER_VIP"
}

#
# ALREADY HAVE BACKEND SERVICE FROM K8s SERVICE OBJECT (NEG)
#

# # Regional health check
# resource "google_compute_region_health_check" "default" {
#   name   = "l7-ilb-hc"
#   region = var.region
#   http_health_check {
#     port_specification = "USE_SERVING_PORT"
#   }
# }

# # Regional backend service
# resource "google_compute_region_backend_service" "default" {
#   name                  = "l7-ilb-backend-service"
#   region                = var.region
#   protocol              = "HTTP"
#   port_name             = "http-server"
#   load_balancing_scheme = "INTERNAL_MANAGED"
#   timeout_sec           = 10
#   health_checks         = [google_compute_region_health_check.default.id]
#   backend {
#     group           = google_compute_region_instance_group_manager.default.instance_group
#     balancing_mode  = "UTILIZATION"
#     capacity_scaler = 1.0
#   }
# }

# Regional forwarding rule
resource "google_compute_forwarding_rule" "default" {
  name                  = "l7-ilb-forwarding-rule"
  region                = var.region
#   depends_on            = [google_compute_subnetwork.proxy_subnet]
  ip_protocol           = "TCP"
  ip_address            = google_compute_address.default.id
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "443"
  target                = var.neg-service-name
  network               = var.network
  subnetwork            = var.subnetwork
  network_tier          = "PREMIUM"
}

# Self-signed regional SSL certificate for testing
resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "default" {
  private_key_pem = tls_private_key.default.private_key_pem

  # Certificate expires after 12 hours.
  validity_period_hours = 12

  # Generate a new certificate if Terraform is run within three
  # hours of the certificate's expiration time.
  early_renewal_hours = 3

  # Reasonable set of uses for a server SSL certificate.
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = ["samweeks.me", "hello-ingress-tf.samweeks.me"]

  subject {
    common_name  = "samweeks.me"
    organization = "Sam Weeks"
  }
}

resource "google_compute_region_ssl_certificate" "default" {
  name_prefix = "cert-for-${var.neg-service-name}-"
  private_key = tls_private_key.default.private_key_pem
  certificate = tls_self_signed_cert.default.cert_pem
  region      = var.region
  lifecycle {
    create_before_destroy = true
  }
}

# Regional URL map
resource "google_compute_region_url_map" "https_lb" {
  name            = "l7-ilb-regional-url-map"
  region          = var.region
  default_service = var.neg-service-name

  host_rule {
    hosts        = ["samweeks.me", "hello-ingress.samweeks.me"]
    path_matcher = "allpaths"
  }

}

# Regional target HTTPS proxy
resource "google_compute_region_target_https_proxy" "default" {
  name             = "l7-ilb-target-https-proxy"
  region           = var.region
  url_map          = google_compute_region_url_map.https_lb.id
  ssl_certificates = [google_compute_region_ssl_certificate.default.self_link]
}

# # Instance template
# resource "google_compute_instance_template" "default" {
#   name         = "l7-ilb-mig-template"
#   machine_type = "e2-small"
#   tags         = ["http-server"]
#   network_interface {
#     network    = google_compute_network.default.id
#     subnetwork = google_compute_subnetwork.default.id
#     access_config {
#       # add external ip to fetch packages
#     }
#   }
#   disk {
#     source_image = "debian-cloud/debian-10"
#     auto_delete  = true
#     boot         = true
#   }

#   # install nginx and serve a simple web page
#   metadata = {
#     startup-script = <<-EOF1
#       #! /bin/bash
#       set -euo pipefail

#       export DEBIAN_FRONTEND=noninteractive
#       apt-get update
#       apt-get install -y nginx-light jq

#       NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
#       IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
#       METADATA=$(curl -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" | jq 'del(.["startup-script"])')

#       cat <<EOF > /var/www/html/index.html
#       <pre>
#       Name: $NAME
#       IP: $IP
#       Metadata: $METADATA
#       </pre>
#       EOF
#     EOF1
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
# }



# # Regional MIG
# resource "google_compute_region_instance_group_manager" "default" {
#   name   = "l7-ilb-mig1"
#   region = var.region
#   version {
#     instance_template = google_compute_instance_template.default.id
#     name              = "primary"
#   }
#   named_port {
#     name = "http-server"
#     port = 80
#   }
#   base_instance_name = "vm"
#   target_size        = 2
# }

# # Allow all access to health check ranges
# resource "google_compute_firewall" "default" {
#   name          = "l7-ilb-fw-allow-hc"
#   direction     = "INGRESS"
#   network       = google_compute_network.default.id
#   source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20"]
#   allow {
#     protocol = "tcp"
#   }
# }

# Allow http from proxy subnet to backends
resource "google_compute_firewall" "backends" {
  name          = "l7-ilb-fw-allow-ilb-to-backends"
  direction     = "INGRESS"
  network       = var.network
  source_ranges = ["10.0.0.0/24"]
  target_tags   = ["http-server"]
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }
}

# # Test instance
# resource "google_compute_instance" "default" {
#   name         = "l7-ilb-test-vm"
#   zone         = "europe-west1-b"
#   machine_type = "e2-small"
#   network_interface {
#     network    = google_compute_network.default.id
#     subnetwork = google_compute_subnetwork.default.id
#   }
#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-10"
#     }
#   }
# }

### HTTP-to-HTTPS redirect ###

# Regional forwarding rule
resource "google_compute_forwarding_rule" "redirect" {
  name                  = "l7-ilb-redirect"
  region                = var.region
  ip_protocol           = "TCP"
  ip_address            = google_compute_address.default.id # Same as HTTPS load balancer
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.default.id
  network               = var.network
  subnetwork            = var.subnetwork
  network_tier          = "PREMIUM"
}

# Regional HTTP proxy
resource "google_compute_region_target_http_proxy" "default" {
  name    = "l7-ilb-target-http-proxy"
  region  = var.region
  url_map = google_compute_region_url_map.redirect.id
}

# Regional URL map
resource "google_compute_region_url_map" "redirect" {
  name            = "l7-ilb-redirect-url-map"
  region          = var.region
  default_service = var.neg-service-name
  host_rule {
    hosts        = ["samweeks.me", "hello-ingress.samweeks.me"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = var.neg-service-name
    path_rule {
      paths = ["/"]
      url_redirect {
        https_redirect         = true
        host_redirect          = "10.0.1.5:443"
        redirect_response_code = "PERMANENT_REDIRECT"
        strip_query            = true
      }
    }
  }
}