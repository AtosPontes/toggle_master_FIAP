resource "kubernetes_namespace_v1" "auth_service" {
  metadata {
    name = "auth_service"
  }
}

resource "kubernetes_namespace_v1" "flag_service" {
  metadata {
    name = "flag_service"
  }
}

resource "kubernetes_namespace_v1" "targeting_service" {
  metadata {
    name = "targeting_service"
  }
}

resource "kubernetes_namespace_v1" "evaluation_service" {
  metadata {
    name = "evaluation_service"
  }
}

resource "kubernetes_namespace_v1" "analytics_service" {
  metadata {
    name = "analytics_service"
  }
}