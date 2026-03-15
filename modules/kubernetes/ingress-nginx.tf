resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  set = [{
    name  = "controller.ingressClassResource.name"
    value = "nginx"
  }]

  set = [{
    name  = "controller.ingressClass"
    value = "nginx"
  }]

  set = [{
    name  = "controller.service.type"
    value = "LoadBalancer"
  }]
}