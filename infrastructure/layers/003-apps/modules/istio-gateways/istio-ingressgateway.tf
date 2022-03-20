resource "kubernetes_deployment" "istio_ingressgateway" {
  depends_on = [kubernetes_namespace.gateways]
  metadata {
    name = "istio-ingressgateway"
    namespace = var.istiogateway-namespace
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "istio-ingressgateway"

        istio = "ingressgateway"
      }
    }

    template {
  metadata {
        labels = {
          app = "istio-ingressgateway"

          istio = "ingressgateway"
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

        service_account_name = "istio-ingressgateway"
      }
    }
  }
}

resource "kubernetes_pod_disruption_budget" "istio_ingressgateway" {
  depends_on = [kubernetes_namespace.gateways]
  metadata {
    name = "istio-ingressgateway"
    namespace = var.istiogateway-namespace
  }

  spec {
    selector {
      match_labels = {
        app = "istio-ingressgateway"

        istio = "ingressgateway"
      }
    }

    max_unavailable = "1"
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "istio_ingressgateway" {
  depends_on = [kubernetes_namespace.gateways]
  metadata {
    name = "istio-ingressgateway"
    namespace = var.istiogateway-namespace
  }

  spec {
    scale_target_ref {
      kind        = "Deployment"
      name        = "istio-ingressgateway"
      api_version = "apps/v1"
    }

    min_replicas = 3
    max_replicas = 5

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type = "Utilization"
          average_utilization = 80
        }
      }
    }
  }
}

resource "kubernetes_role" "istio_ingressgateway" {
  depends_on = [kubernetes_namespace.gateways]
  metadata {
    name = "istio-ingressgateway"
    namespace = var.istiogateway-namespace
  }

  rule {
    verbs      = ["get", "watch", "list"]
    api_groups = [""]
    resources  = ["secrets"]
  }
}

resource "kubernetes_role_binding" "istio_ingressgateway" {
  depends_on = [kubernetes_namespace.gateways]
  metadata {
    name = "istio-ingressgateway"
    namespace = var.istiogateway-namespace
  }

  subject {
    kind = "ServiceAccount"
    name = "istio-ingressgateway"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "istio-ingressgateway"
  }
}

resource "kubernetes_service" "istio_ingressgateway" {
  depends_on = [kubernetes_namespace.gateways]
  metadata {
    name = "istio-ingressgateway"
    namespace = var.istiogateway-namespace

    labels = {
      app = "istio-ingressgateway"

      istio = "ingressgateway"
    }
  }

  spec {
    port {
      name        = "status-port"
      protocol    = "TCP"
      port        = 15021
      target_port = "15021"
    }

    port {
      name = "http2"
      port = 80
    }

    port {
      name = "https"
      port = 443
    }

    selector = {
      app = "istio-ingressgateway"

      istio = "ingressgateway"
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_service_account" "istio_ingressgateway" {
  depends_on = [kubernetes_namespace.gateways]
  metadata {
    name = "istio-ingressgateway"
    namespace = var.istiogateway-namespace
  }
}

