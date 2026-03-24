locals {
  ingress_entry = coalesce(module.kubernetes.ingress_nginx_hostname, module.kubernetes.ingress_nginx_ip)
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks_cluster.endpoint
}

output "ingress_nginx_hostname" {
  description = "External hostname exposed by ingress-nginx"
  value       = module.kubernetes.ingress_nginx_hostname
}

output "ingress_nginx_ip" {
  description = "External IP exposed by ingress-nginx when available"
  value       = module.kubernetes.ingress_nginx_ip
}

output "load_balancer_url" {
  description = "Base URL of the public ingress entrypoint"
  value       = local.ingress_entry != null ? "http://${local.ingress_entry}" : null
}

output "service_urls" {
  description = "Public URLs exposed through ingress-nginx for the application services"
  value = local.ingress_entry != null ? {
    auth_service       = "http://${local.ingress_entry}/auth-service"
    flag_service       = "http://${local.ingress_entry}/flag-service"
    targeting_service  = "http://${local.ingress_entry}/targeting-service"
    evaluation_service = "http://${local.ingress_entry}/evaluation-service"
    analytics_service  = "http://${local.ingress_entry}/analytics-service"
  } : null
}

output "argocd_ingress_hostname" {
  description = "Hostname exposed for the ArgoCD ingress"
  value       = try(module.argocd[0].argocd_ingress_hostname, null)
}

output "argocd_url" {
  description = "Public URL for the ArgoCD UI"
  value       = try("http://${module.argocd[0].argocd_ingress_hostname}/argocd", null)
}

output "infrastructure_endpoints" {
  description = "Useful infrastructure endpoints created by Terraform"
  value = {
    auth_db_endpoint      = module.resources.db_auth_endpoint
    flag_db_endpoint      = module.resources.db_flag_endpoint
    targeting_db_endpoint = module.resources.db_targeting_endpoint
    evaluation_redis_host = module.resources.evaluation_db_endpoint
    sqs_queue_url         = module.resources.sqs_queue_url
    dynamodb_table_name   = module.resources.dynamodb_url
  }
}
