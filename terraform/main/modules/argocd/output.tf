output "argocd_ingress_hostname" {
  description = "Hostname exposed for the ArgoCD ingress when the Load Balancer is ready"
  value       = try(kubernetes_ingress_v1.argocd_server.status[0].load_balancer[0].ingress[0].hostname, null)
}
