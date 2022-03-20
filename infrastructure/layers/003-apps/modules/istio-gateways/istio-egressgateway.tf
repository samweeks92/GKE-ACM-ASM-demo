resource "kubernetes_deployment" "istio_egressgateway" {
  depends_on = [kubernetes_namespace.gateways]
  metadata {
    name = "istio-egressgateway"
    namespace = var.istiogateway-namespace
  }

  spec {
    selector {
      match_labels = {
        app = "istio-egressgateway"

        istio = "egressgateway"
      }
    }

    template {
      metadata {
        labels = {
          app = "istio-egressgateway"

          istio = "egressgateway"
        }

        annotations = {
          "inject.istio.io/templates" = "gateway"
        }
      }

      spec {
        container {
          name  = "istio-proxy"
          image = "auto"

          resources {
            limits = {
              cpu = "2"

              memory = "1Gi"
            }

            requests = {
              cpu = "100m"

              memory = "128Mi"
            }
          }
        }

        service_account_name = "istio-egressgateway"
      }
    }
  }
}

resource "kubernetes_pod_disruption_budget" "istio_egressgateway" {
  depends_on = [kubernetes_namespace.gateways]
  metadata {
    name = "istio-egressgateway"
    namespace = var.istiogateway-namespace
  }

  spec {
    min_available = "1"

    selector {
      match_labels = {
        app = "istio-egressgateway"

        istio = "egressgateway"
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "istio_egressgateway" {
  depends_on = [kubernetes_namespace.gateways]
  metadata {
    name = "istio-egressgateway"
    namespace = var.istiogateway-namespace
  }

  spec {
    scale_target_ref {
      kind        = "Deployment"
      name        = "istio-egressgateway"
      api_version = "apps/v1"
    }

    min_replicas = 2
    max_replicas = 5

    metric {
      type = "Resource"

      resource {
        name = "cpu"
      }
    }
  }
}

resource "kubernetes_role" "istio_egressgateway" {
  depends_on = [kubernetes_namespace.gateways]
  metadata {
    name = "istio-egressgateway"
    namespace = var.istiogateway-namespace
  }

  rule {
    verbs      = ["get", "watch", "list"]
    api_groups = [""]
    resources  = ["secrets"]
  }
}

resource "kubernetes_role_binding" "istio_egressgateway" {
  depends_on = [kubernetes_namespace.gateways]
  metadata {
    name = "istio-egressgateway"
    namespace = var.istiogateway-namespace
  }

  subject {
    kind = "ServiceAccount"
    name = "istio-egressgateway"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "istio-egressgateway"
  }
}

resource "kubernetes_service" "istio_egressgateway" {
  depends_on = [kubernetes_namespace.gateways]
  metadata {
    name = "istio-egressgateway"
    namespace = var.istiogateway-namespace

    labels = {
      app = "istio-egressgateway"

      istio = "egressgateway"
    }
  }

  spec {
    port {
      name = "http2"
      port = 80
    }

    port {
      name = "https"
      port = 443
    }

    selector = {
      app = "istio-egressgateway"

      istio = "egressgateway"
    }
  }
}

resource "kubernetes_service_account" "istio_egressgateway" {
  depends_on = [kubernetes_namespace.gateways]
  metadata {
    name = "istio-egressgateway"
    namespace = var.istiogateway-namespace
  }
}

