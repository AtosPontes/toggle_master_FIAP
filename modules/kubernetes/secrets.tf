data "aws_region" "current" {}

resource "kubernetes_secret_v1" "auth_db_secret" {
  depends_on = [kubernetes_namespace_v1.auth_service]

  metadata {
    name      = "auth-db-secret"
    namespace = "auth-service"
  }

  data = {
    POSTGRES_DB       = "auth_db"
    POSTGRES_USER     = var.db_user
    POSTGRES_PASSWORD = var.db_password
    POSTGRES_PORT     = "5432"
    MASTER_KEY        = var.master_key
    SERVICE_API_KEY   = var.service_api_key
  }

  type = "Opaque"
}

resource "kubernetes_secret_v1" "auth_db_secret_host" {
  depends_on = [kubernetes_namespace_v1.auth_service]

  metadata {
    name      = "auth-db-secret-host"
    namespace = "auth-service"
  }

  data = {
    POSTGRES_HOST = var.db_auth_endpoint
  }

  type = "Opaque"
}

resource "kubernetes_secret_v1" "flag_db_secret" {
  depends_on = [kubernetes_namespace_v1.flag_service]

  metadata {
    name      = "flag-db-secret"
    namespace = "flag-service"
  }

  data = {
    AUTH_SERVICE_URL  = "http://app-auth-service.auth-service.svc.cluster.local:8001"
    POSTGRES_DB       = "flag_db"
    POSTGRES_USER     = var.db_user
    POSTGRES_PASSWORD = var.db_password
    POSTGRES_PORT     = "5432"
  }

  type = "Opaque"
}

resource "kubernetes_secret_v1" "flag_db_secret_host" {
  depends_on = [kubernetes_namespace_v1.flag_service]

  metadata {
    name      = "flag-db-secret-host"
    namespace = "flag-service"
  }

  data = {
    POSTGRES_HOST = var.db_flag_endpoint
  }

  type = "Opaque"
}

resource "kubernetes_secret_v1" "targeting_db_secret" {
  depends_on = [kubernetes_namespace_v1.targeting_service]

  metadata {
    name      = "targeting-db-secret"
    namespace = "targeting-service"
  }

  data = {
    AUTH_SERVICE_URL  = "http://app-auth-service.auth-service.svc.cluster.local:8001"
    POSTGRES_DB       = "targeting_db"
    POSTGRES_USER     = var.db_user
    POSTGRES_PASSWORD = var.db_password
    POSTGRES_PORT     = "5432"
  }

  type = "Opaque"
}

resource "kubernetes_secret_v1" "targeting_db_secret_host" {
  depends_on = [kubernetes_namespace_v1.targeting_service]

  metadata {
    name      = "targeting-db-secret-host"
    namespace = "targeting-service"
  }

  data = {
    POSTGRES_HOST = var.db_targeting_endpoint
  }

  type = "Opaque"
}

resource "kubernetes_secret_v1" "evaluation_db_secret_host" {
  depends_on = [kubernetes_namespace_v1.evaluation_service]

  metadata {
    name      = "evaluation-db-secret-host"
    namespace = "evaluation-service"
  }

  data = {
    REDIS_URL   = "redis://${var.evaluation_db_endpoint}:6379"
    AWS_REGION  = data.aws_region.current.id
    AWS_SQS_URL = var.sqs_queue_url
  }

  type = "Opaque"
}

resource "kubernetes_secret_v1" "evaluation_db_secret" {
  depends_on = [kubernetes_namespace_v1.evaluation_service]

  metadata {
    name      = "evaluation-db-secret"
    namespace = "evaluation-service"
  }

  data = {
    FLAG_SERVICE_URL      = "http://app-flag-service.flag-service.svc.cluster.local:8002"
    SERVICE_API_KEY       = var.service_api_key
    TARGETING_SERVICE_URL = "http://app-targeting-service.targeting-service.svc.cluster.local:8003"
  }

  type = "Opaque"
}

resource "kubernetes_secret_v1" "analytics_db_secret_host" {
  depends_on = [kubernetes_namespace_v1.analytics_service]

  metadata {
    name      = "analytics-db-secret-host"
    namespace = "analytics-service"
  }

  data = {
    AWS_DYNAMODB_TABLE = var.dynamodb_url
    AWS_REGION         = data.aws_region.current.id
    AWS_SQS_URL        = var.sqs_queue_url
  }

  type = "Opaque"
}

resource "kubernetes_secret_v1" "analytics_db_secret" {
  depends_on = [kubernetes_namespace_v1.analytics_service]

  metadata {
    name      = "analytics-db-secret"
    namespace = "analytics-service"
  }

  data = {
    SERVICE_API_KEY = var.service_api_key
  }

  type = "Opaque"
}
