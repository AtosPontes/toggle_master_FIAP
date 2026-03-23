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
  sensitive   = true
}

variable "master_key" {
  type        = string
  description = "Master key used by auth-service to create API keys"
  sensitive   = true
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID used in ARNs and ECR registry URLs"
}

variable "enable_argocd" {
  type        = bool
  description = "Enable ArgoCD installation and GitOps Applications"
  default     = true
}

variable "gitops_repo_url" {
  type        = string
  description = "Git repository URL with Kubernetes manifests for ArgoCD"
  default     = ""
}

variable "gitops_target_revision" {
  type        = string
  description = "Git revision/branch monitored by ArgoCD"
  default     = "main"
}

variable "service_api_key" {
  type        = string
  description = "Internal service API key"
  sensitive   = true
}

variable "argocd_admin_password_hash" {
  type        = string
  description = "BCrypt hash for the ArgoCD admin password"
  sensitive   = true
}
