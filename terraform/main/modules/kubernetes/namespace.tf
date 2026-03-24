resource "kubernetes_namespace_v1" "auth_service" {
  metadata {
    name = "auth-service"
  }
}

resource "kubernetes_namespace_v1" "flag_service" {
  metadata {
    name = "flag-service"
  }
}

resource "kubernetes_namespace_v1" "targeting_service" {
  metadata {
    name = "targeting-service"
  }
}

resource "kubernetes_namespace_v1" "evaluation_service" {
  metadata {
    name = "evaluation-service"
  }
}

resource "kubernetes_namespace_v1" "analytics_service" {
  metadata {
    name = "analytics-service"
  }
}