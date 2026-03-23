variable "gitops_repo_url" {
  type        = string
  description = "Git repository URL monitored by ArgoCD"
}

variable "gitops_revision" {
  type        = string
  description = "Git revision monitored by ArgoCD"
}

variable "argocd_admin_password_hash" {
  type        = string
  description = "BCrypt hash for the ArgoCD admin password"
  sensitive   = true
}
