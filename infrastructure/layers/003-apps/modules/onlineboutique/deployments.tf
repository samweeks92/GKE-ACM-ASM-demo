resource "kubernetes_service_account" "email" {
  depends_on = [kubernetes_namespace.onlineboutique]
  metadata {
    name      = "email"
    namespace = "email"
  }
}

resource "kubernetes_deployment" "emailservice" {

  depends_on = [kubernetes_namespace.onlineboutique, kubernetes_service_account.email,]
  metadata {
    name      = "emailservice"
    namespace = "email"
  }

  spec {
    selector {
      match_labels = {
        app = "emailservice"
      }
    }

    template {
      metadata {
        labels = {
          app = "emailservice"
        }
      }

      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/emailservice:v0.3.6"

          port {
            container_port = 8080
          }

          env {
            name  = "PORT"
            value = "8080"
          }

          env {
            name  = "DISABLE_TRACING"
            value = "1"
          }

          env {
            name  = "DISABLE_PROFILER"
            value = "1"
          }

          resources {
            limits = {
              cpu = "200m"

              memory = "128Mi"
            }

            requests = {
              cpu = "100m"

              memory = "64Mi"
            }
          }

          liveness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:8080"]
            }

            period_seconds = 5
          }

          readiness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:8080"]
            }

            period_seconds = 5
          }
        }

        service_account_name = "email"
      }
    }
  }
}

resource "kubernetes_service_account" "checkout" {
  depends_on = [kubernetes_namespace.onlineboutique]
  metadata {
    name      = "checkout"
    namespace = "checkout"
  }
}

resource "kubernetes_deployment" "checkoutservice" {
  depends_on = [kubernetes_namespace.onlineboutique, kubernetes_service_account.checkout]
  metadata {
    name      = "checkoutservice"
    namespace = "checkout"
  }

  spec {
    selector {
      match_labels = {
        app = "checkoutservice"
      }
    }

    template {
      metadata {
        labels = {
          app = "checkoutservice"
        }
      }

      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/checkoutservice:v0.3.6"

          port {
            container_port = 5050
          }

          env {
            name  = "PORT"
            value = "5050"
          }

          env {
            name  = "PRODUCT_CATALOG_SERVICE_ADDR"
            value = "productcatalogservice.product-catalog.svc.cluster.local:3550"
          }

          env {
            name  = "SHIPPING_SERVICE_ADDR"
            value = "shippingservice.shipping.svc.cluster.local:50051"
          }

          env {
            name  = "PAYMENT_SERVICE_ADDR"
            value = "paymentservice.payment.svc.cluster.local:50051"
          }

          env {
            name  = "EMAIL_SERVICE_ADDR"
            value = "emailservice.email.svc.cluster.local:5000"
          }

          env {
            name  = "CURRENCY_SERVICE_ADDR"
            value = "currencyservice.currency.svc.cluster.local:7000"
          }

          env {
            name  = "CART_SERVICE_ADDR"
            value = "cartservice.cart.svc.cluster.local:7070"
          }

          env {
            name  = "DISABLE_STATS"
            value = "1"
          }

          env {
            name  = "DISABLE_TRACING"
            value = "1"
          }

          env {
            name  = "DISABLE_PROFILER"
            value = "1"
          }

          resources {
            limits = {
              cpu = "200m"

              memory = "128Mi"
            }

            requests = {
              cpu = "100m"

              memory = "64Mi"
            }
          }

          liveness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:5050"]
            }
          }

          readiness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:5050"]
            }
          }
        }

        service_account_name = "checkout"
      }
    }
  }
}

resource "kubernetes_service_account" "recommendation" {
  depends_on = [kubernetes_namespace.onlineboutique]
  metadata {
    name      = "recommendation"
    namespace = "recommendation"
  }
}

resource "kubernetes_deployment" "recommendationservice" {
  depends_on = [kubernetes_namespace.onlineboutique, kubernetes_service_account.recommendation]
  metadata {
    name      = "recommendationservice"
    namespace = "recommendation"
  }

  spec {
    selector {
      match_labels = {
        app = "recommendationservice"
      }
    }

    template {
      metadata {
        labels = {
          app = "recommendationservice"
        }
      }

      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/recommendationservice:v0.3.6"

          port {
            container_port = 8080
          }

          env {
            name  = "PORT"
            value = "8080"
          }

          env {
            name  = "PRODUCT_CATALOG_SERVICE_ADDR"
            value = "productcatalogservice.product-catalog.svc.cluster.local:3550"
          }

          env {
            name  = "DISABLE_TRACING"
            value = "1"
          }

          env {
            name  = "DISABLE_PROFILER"
            value = "1"
          }

          env {
            name  = "DISABLE_DEBUGGER"
            value = "1"
          }

          resources {
            limits = {
              cpu = "200m"

              memory = "450Mi"
            }

            requests = {
              cpu = "100m"

              memory = "220Mi"
            }
          }

          liveness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:8080"]
            }

            period_seconds = 5
          }

          readiness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:8080"]
            }

            period_seconds = 5
          }
        }

        termination_grace_period_seconds = 5
        service_account_name             = "recommendation"
      }
    }
  }
}

resource "kubernetes_service_account" "frontend" {
  depends_on = [kubernetes_namespace.onlineboutique]
  metadata {
    name      = "frontend"
    namespace = "frontend"
  }
}

resource "kubernetes_deployment" "frontend" {
  depends_on = [kubernetes_namespace.onlineboutique, kubernetes_service_account.frontend]
  metadata {
    name      = "frontend"
    namespace = "frontend"
  }

  spec {
    selector {
      match_labels = {
        app = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "frontend"
        }

        annotations = {
          "sidecar.istio.io/rewriteAppHTTPProbers" = "true"
        }
      }

      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/frontend:v0.3.6"

          port {
            container_port = 8080
          }

          env {
            name  = "PORT"
            value = "8080"
          }

          env {
            name  = "PRODUCT_CATALOG_SERVICE_ADDR"
            value = "productcatalogservice.product-catalog.svc.cluster.local:3550"
          }

          env {
            name  = "CURRENCY_SERVICE_ADDR"
            value = "currencyservice.currency.svc.cluster.local:7000"
          }

          env {
            name  = "CART_SERVICE_ADDR"
            value = "cartservice.cart.svc.cluster.local:7070"
          }

          env {
            name  = "RECOMMENDATION_SERVICE_ADDR"
            value = "recommendationservice.recommendation.svc.cluster.local:8080"
          }

          env {
            name  = "SHIPPING_SERVICE_ADDR"
            value = "shippingservice.shipping.svc.cluster.local:50051"
          }

          env {
            name  = "CHECKOUT_SERVICE_ADDR"
            value = "checkoutservice.checkout.svc.cluster.local:5050"
          }

          env {
            name  = "AD_SERVICE_ADDR"
            value = "adservice.ad.svc.cluster.local:9555"
          }

          env {
            name  = "DISABLE_TRACING"
            value = "1"
          }

          env {
            name  = "DISABLE_PROFILER"
            value = "1"
          }

          resources {
            limits = {
              cpu = "200m"

              memory = "128Mi"
            }

            requests = {
              cpu = "100m"

              memory = "64Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/_healthz"
              port = "8080"

              http_header {
                name  = "Cookie"
                value = "shop_session-id=x-liveness-probe"
              }
            }

            initial_delay_seconds = 10
          }

          readiness_probe {
            http_get {
              path = "/_healthz"
              port = "8080"

              http_header {
                name  = "Cookie"
                value = "shop_session-id=x-readiness-probe"
              }
            }

            initial_delay_seconds = 10
          }
        }

        service_account_name = "frontend"
      }
    }
  }
}

resource "kubernetes_service_account" "payment" {
  depends_on = [kubernetes_namespace.onlineboutique]
  metadata {
    name      = "payment"
    namespace = "payment"
  }
}

resource "kubernetes_deployment" "paymentservice" {
  depends_on = [kubernetes_namespace.onlineboutique, kubernetes_service_account.payment]
  metadata {
    name      = "paymentservice"
    namespace = "payment"
  }

  spec {
    selector {
      match_labels = {
        app = "paymentservice"
      }
    }

    template {
      metadata {
        labels = {
          app = "paymentservice"
        }
      }

      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/paymentservice:v0.3.6"

          port {
            container_port = 50051
          }

          env {
            name  = "PORT"
            value = "50051"
          }

          env {
            name  = "DISABLE_TRACING"
            value = "1"
          }

          env {
            name  = "DISABLE_PROFILER"
            value = "1"
          }

          env {
            name  = "DISABLE_DEBUGGER"
            value = "1"
          }

          resources {
            limits = {
              cpu = "200m"

              memory = "128Mi"
            }

            requests = {
              cpu = "100m"

              memory = "64Mi"
            }
          }

          liveness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:50051"]
            }
          }

          readiness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:50051"]
            }
          }
        }

        termination_grace_period_seconds = 5
        service_account_name             = "payment"
      }
    }
  }
}

resource "kubernetes_service_account" "product_catalog" {
  depends_on = [kubernetes_namespace.onlineboutique]
  metadata {
    name      = "product-catalog"
    namespace = "product-catalog"
  }
}

resource "kubernetes_deployment" "productcatalogservice" {
  depends_on = [kubernetes_namespace.onlineboutique, kubernetes_service_account.product_catalog]
  metadata {
    name      = "productcatalogservice"
    namespace = "product-catalog"
  }

  spec {
    selector {
      match_labels = {
        app = "productcatalogservice"
      }
    }

    template {
      metadata {
        labels = {
          app = "productcatalogservice"
        }
      }

      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/productcatalogservice:v0.3.6"

          port {
            container_port = 3550
          }

          env {
            name  = "PORT"
            value = "3550"
          }

          env {
            name  = "DISABLE_STATS"
            value = "1"
          }

          env {
            name  = "DISABLE_TRACING"
            value = "1"
          }

          env {
            name  = "DISABLE_PROFILER"
            value = "1"
          }

          resources {
            limits = {
              cpu = "200m"

              memory = "128Mi"
            }

            requests = {
              cpu = "100m"

              memory = "64Mi"
            }
          }

          liveness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:3550"]
            }
          }

          readiness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:3550"]
            }
          }
        }

        termination_grace_period_seconds = 5
        service_account_name             = "product-catalog"
      }
    }
  }
}

resource "kubernetes_service_account" "cart" {
  depends_on = [kubernetes_namespace.onlineboutique]
  metadata {
    name      = "cart"
    namespace = "cart"
  }
}

resource "kubernetes_deployment" "cartservice" {
  depends_on = [kubernetes_namespace.onlineboutique, kubernetes_service_account.cart]
  metadata {
    name      = "cartservice"
    namespace = "cart"
  }

  spec {
    selector {
      match_labels = {
        app = "cartservice"
      }
    }

    template {
      metadata {
        labels = {
          app = "cartservice"
        }
      }

      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/cartservice:v0.3.6"

          port {
            container_port = 7070
          }

          env {
            name = "REDIS_ADDR"
          }

          resources {
            limits = {
              cpu = "300m"

              memory = "128Mi"
            }

            requests = {
              cpu = "200m"

              memory = "64Mi"
            }
          }

          liveness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:7070", "-rpc-timeout=5s"]
            }

            initial_delay_seconds = 15
            period_seconds        = 10
          }

          readiness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:7070", "-rpc-timeout=5s"]
            }

            initial_delay_seconds = 15
          }
        }

        termination_grace_period_seconds = 5
        service_account_name             = "cart"
      }
    }
  }
}

resource "kubernetes_service_account" "loadgenerator" {
  depends_on = [kubernetes_namespace.onlineboutique]
  metadata {
    name      = "loadgenerator"
    namespace = "loadgenerator"
  }
}

resource "kubernetes_deployment" "loadgenerator" {
  depends_on = [kubernetes_namespace.onlineboutique, kubernetes_service_account.loadgenerator]
  metadata {
    name      = "loadgenerator"
    namespace = "loadgenerator"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "loadgenerator"
      }
    }

    template {
      metadata {
        labels = {
          app = "loadgenerator"
        }

        annotations = {
          "sidecar.istio.io/rewriteAppHTTPProbers" = "true"
        }
      }

      spec {
        container {
          name  = "main"
          image = "gcr.io/google-samples/microservices-demo/loadgenerator:v0.3.6"

          env {
            name  = "FRONTEND_ADDR"
            value = "frontend.frontend.svc.cluster.local:80"
          }

          env {
            name  = "USERS"
            value = "10"
          }

          resources {
            limits = {
              cpu = "500m"

              memory = "512Mi"
            }

            requests = {
              cpu = "300m"

              memory = "256Mi"
            }
          }
        }

        restart_policy                   = "Always"
        termination_grace_period_seconds = 5
        service_account_name             = "loadgenerator"
      }
    }
  }
}

resource "kubernetes_service_account" "currency" {
  depends_on = [kubernetes_namespace.onlineboutique]
  metadata {
    name      = "currency"
    namespace = "currency"
  }
}

resource "kubernetes_deployment" "currencyservice" {
  depends_on = [kubernetes_namespace.onlineboutique, kubernetes_service_account.currency]
  metadata {
    name      = "currencyservice"
    namespace = "currency"
  }

  spec {
    selector {
      match_labels = {
        app = "currencyservice"
      }
    }

    template {
      metadata {
        labels = {
          app = "currencyservice"
        }
      }

      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/currencyservice:v0.3.6"

          port {
            name           = "grpc"
            container_port = 7000
          }

          env {
            name  = "PORT"
            value = "7000"
          }

          env {
            name  = "DISABLE_TRACING"
            value = "1"
          }

          env {
            name  = "DISABLE_PROFILER"
            value = "1"
          }

          env {
            name  = "DISABLE_DEBUGGER"
            value = "1"
          }

          resources {
            limits = {
              cpu = "200m"

              memory = "128Mi"
            }

            requests = {
              cpu = "100m"

              memory = "64Mi"
            }
          }

          liveness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:7000"]
            }
          }

          readiness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:7000"]
            }
          }
        }

        termination_grace_period_seconds = 5
        service_account_name             = "currency"
      }
    }
  }
}

resource "kubernetes_service_account" "shipping" {
  depends_on = [kubernetes_namespace.onlineboutique]
  metadata {
    name      = "shipping"
    namespace = "shipping"
  }
}

resource "kubernetes_deployment" "shippingservice" {
  depends_on = [kubernetes_namespace.onlineboutique, kubernetes_service_account.shipping]
  metadata {
    name      = "shippingservice"
    namespace = "shipping"
  }

  spec {
    selector {
      match_labels = {
        app = "shippingservice"
      }
    }

    template {
      metadata {
        labels = {
          app = "shippingservice"
        }
      }

      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/shippingservice:v0.3.6"

          port {
            container_port = 50051
          }

          env {
            name  = "PORT"
            value = "50051"
          }

          env {
            name  = "DISABLE_STATS"
            value = "1"
          }

          env {
            name  = "DISABLE_TRACING"
            value = "1"
          }

          env {
            name  = "DISABLE_PROFILER"
            value = "1"
          }

          resources {
            limits = {
              cpu = "200m"

              memory = "128Mi"
            }

            requests = {
              cpu = "100m"

              memory = "64Mi"
            }
          }

          liveness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:50051"]
            }
          }

          readiness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:50051"]
            }

            period_seconds = 5
          }
        }

        service_account_name = "shipping"
      }
    }
  }
}

resource "kubernetes_service_account" "ad" {
  depends_on = [kubernetes_namespace.onlineboutique]
  metadata {
    name      = "ad"
    namespace = "ad"
  }
}

resource "kubernetes_deployment" "adservice" {
  depends_on = [kubernetes_namespace.onlineboutique, kubernetes_service_account.ad]
  metadata {
    name      = "adservice"
    namespace = "ad"
  }

  spec {
    selector {
      match_labels = {
        app = "adservice"
      }
    }

    template {
      metadata {
        labels = {
          app = "adservice"
        }
      }

      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/adservice:v0.3.6"

          port {
            container_port = 9555
          }

          env {
            name  = "PORT"
            value = "9555"
          }

          env {
            name  = "DISABLE_STATS"
            value = "1"
          }

          env {
            name  = "DISABLE_TRACING"
            value = "1"
          }

          resources {
            limits = {
              cpu = "300m"

              memory = "300Mi"
            }

            requests = {
              cpu = "200m"

              memory = "180Mi"
            }
          }

          liveness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:9555"]
            }

            initial_delay_seconds = 20
            period_seconds        = 15
          }

          readiness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:9555"]
            }

            initial_delay_seconds = 20
            period_seconds        = 15
          }
        }

        termination_grace_period_seconds = 5
        service_account_name             = "ad"
      }
    }
  }
}

