terraform {
  required_providers {
    kubernetes = {
        configuration_aliases = [kubernetes.my-cluster]
    }
  }
}