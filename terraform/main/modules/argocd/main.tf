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

resource "helm_release" "argocd_root_app" {
  name       = "argocd-root-app"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = "argocd"
  wait       = true
  values = [
    yamlencode({
      applications = {
        "togglemaster-root" = {
          namespace = "argocd"
          project   = "default"
          source = {
            repoURL        = var.gitops_repo_url
            targetRevision = var.gitops_revision
            path           = "gitops/app-of-apps"
          }
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "argocd"
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
    })
  ]
  depends_on = [helm_release.argocd]
}
