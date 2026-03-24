data "kubernetes_service_v1" "ingress_nginx_controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [helm_release.ingress_nginx]
}

output "ingress_nginx_hostname" {
  description = "External hostname exposed by the ingress-nginx LoadBalancer service"
  value       = try(data.kubernetes_service_v1.ingress_nginx_controller.status[0].load_balancer[0].ingress[0].hostname, null)
}

output "ingress_nginx_ip" {
  description = "External IP exposed by the ingress-nginx LoadBalancer service when available"
  value       = try(data.kubernetes_service_v1.ingress_nginx_controller.status[0].load_balancer[0].ingress[0].ip, null)
}
