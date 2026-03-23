output "argocd_ingress_hostname" {
  value = module.argocd[0].argocd_ingress_hostname
}

output "argocd_url" {
  value = "http://${module.argocd[0].argocd_ingress_hostname}/argocd"
}