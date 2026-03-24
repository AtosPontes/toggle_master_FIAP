output "argocd_ingress_hostname" {
  value = kubernetes_ingress_v1.argocd_server.status[0].load_balancer[0].ingress[0].hostname
}