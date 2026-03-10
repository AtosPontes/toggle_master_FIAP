variable "gitops_repo_url" {
  type        = string
  description = "Git repository URL monitored by ArgoCD"
}

variable "gitops_revision" {
  type        = string
  description = "Git revision monitored by ArgoCD"
}
