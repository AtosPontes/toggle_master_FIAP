resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  wait             = true

  set = [
    {
      name  = "server.service.type"
      value = "ClusterIP"
    },
    {
      name  = "configs.params.server\\.insecure"
      value = "true"
    },
    {
      name  = "configs.params.server\\.basehref"
      value = "/argocd"
    },
    {
      name  = "configs.params.server\\.rootpath"
      value = "/argocd"
    },
    {
      name  = "server.ingress.enabled"
      value = "false"
    }
  ]
}

resource "kubernetes_ingress_v1" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = "argocd"
    annotations = {
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      http {
        path {
          path      = "/argocd"
          path_type = "Prefix"

          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.argocd]
}

locals {
  workload_applications = {
    "auth-service" = {
      namespace = "argocd"
      project   = "default"
      source = {
        repoURL        = var.gitops_repo_url
        targetRevision = var.gitops_revision
        path           = "gitops/auth-service"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "auth-service"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
    "flag-service" = {
      namespace = "argocd"
      project   = "default"
      source = {
        repoURL        = var.gitops_repo_url
        targetRevision = var.gitops_revision
        path           = "gitops/flag-service"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "flag-service"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
    "targeting-service" = {
      namespace = "argocd"
      project   = "default"
      source = {
        repoURL        = var.gitops_repo_url
        targetRevision = var.gitops_revision
        path           = "gitops/targeting-service"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "targeting-service"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
    "evaluation-service" = {
      namespace = "argocd"
      project   = "default"
      source = {
        repoURL        = var.gitops_repo_url
        targetRevision = var.gitops_revision
        path           = "gitops/evaluation-service"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "evaluation-service"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
    "analytics-service" = {
      namespace = "argocd"
      project   = "default"
      source = {
        repoURL        = var.gitops_repo_url
        targetRevision = var.gitops_revision
        path           = "gitops/analytics-service"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "analytics-service"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }

  applications = var.enable_workloads ? local.workload_applications : {}
}

resource "helm_release" "argocd_apps" {
  count      = var.enable_workloads ? 1 : 0
  name       = "argocd-apps"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = "argocd"
  wait       = true
  values = [
    yamlencode({
      applications = local.applications
    })
  ]
  depends_on = [helm_release.argocd]
}
