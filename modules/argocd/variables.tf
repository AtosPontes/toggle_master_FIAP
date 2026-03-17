variable "gitops_repo_url" {
  type        = string
  description = "Git repository URL monitored by ArgoCD"
}

variable "enable_workloads" {
  type        = bool
  description = "Whether ArgoCD should manage the five workload applications"
}

variable "gitops_revision" {
  type        = string
  description = "Git revision monitored by ArgoCD"
}
