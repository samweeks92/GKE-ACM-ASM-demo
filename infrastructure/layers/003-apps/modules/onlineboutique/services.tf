resource "kubernetes_service" "emailservice" {
  metadata {
    name      = "emailservice"
    namespace = "email"
  }

  spec {
    port {
      name        = "grpc"
      port        = 5000
      target_port = "8080"
    }

    selector = {
      app = "emailservice"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "checkoutservice" {
  metadata {
    name      = "checkoutservice"
    namespace = "checkout"
  }

  spec {
    port {
      name        = "grpc"
      port        = 5050
      target_port = "5050"
    }

    selector = {
      app = "checkoutservice"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "recommendationservice" {
  metadata {
    name      = "recommendationservice"
    namespace = "recommendation"
  }

  spec {
    port {
      name        = "grpc"
      port        = 8080
      target_port = "8080"
    }

    selector = {
      app = "recommendationservice"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name      = "frontend"
    namespace = "frontend"
  }

  spec {
    port {
      name        = "http"
      port        = 80
      target_port = "8080"
    }

    selector = {
      app = "frontend"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "frontend_external" {
  metadata {
    name      = "frontend-external"
    namespace = "frontend"
  }

  spec {
    port {
      name        = "http"
      port        = 80
      target_port = "8080"
    }

    selector = {
      app = "frontend"
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_service" "paymentservice" {
  metadata {
    name      = "paymentservice"
    namespace = "payment"
  }

  spec {
    port {
      name        = "grpc"
      port        = 50051
      target_port = "50051"
    }

    selector = {
      app = "paymentservice"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "productcatalogservice" {
  metadata {
    name      = "productcatalogservice"
    namespace = "product-catalog"
  }

  spec {
    port {
      name        = "grpc"
      port        = 3550
      target_port = "3550"
    }

    selector = {
      app = "productcatalogservice"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "cartservice" {
  metadata {
    name      = "cartservice"
    namespace = "cart"
  }

  spec {
    port {
      name        = "grpc"
      port        = 7070
      target_port = "7070"
    }

    selector = {
      app = "cartservice"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "currencyservice" {
  metadata {
    name      = "currencyservice"
    namespace = "currency"
  }

  spec {
    port {
      name        = "grpc"
      port        = 7000
      target_port = "7000"
    }

    selector = {
      app = "currencyservice"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "shippingservice" {
  metadata {
    name      = "shippingservice"
    namespace = "shipping"
  }

  spec {
    port {
      name        = "grpc"
      port        = 50051
      target_port = "50051"
    }

    selector = {
      app = "shippingservice"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "adservice" {
  metadata {
    name      = "adservice"
    namespace = "ad"
  }

  spec {
    port {
      name        = "grpc"
      port        = 9555
      target_port = "9555"
    }

    selector = {
      app = "adservice"
    }

    type = "ClusterIP"
  }
}

