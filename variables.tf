# Variable for the CIDR BLOCK to be used for the VPC
variable "cidr_block" {
  type        = string
  description = "Networking CIDR block to be used for the VPC"
}

variable "project_name" {
  type        = string
  description = "Project name to be used to name the resources (name tag)"
}

variable "db_user" {
  type        = string
  description = "User to RDS"
}

variable "db_password" {
  type        = string
  description = "Password to RDS"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID used in ARNs and ECR registry URLs"
}

variable "enable_argocd" {
  type        = bool
  description = "Enable ArgoCD installation and GitOps Applications"
  default     = false
}

variable "gitops_repo_url" {
  type        = string
  description = "Git repository URL with Kubernetes manifests for ArgoCD"
  default     = "https://github.com/AtosPontes/projeto_posgraduacao.git"
}

variable "gitops_target_revision" {
  type        = string
  description = "Git revision/branch monitored by ArgoCD"
  default     = "main"
}
