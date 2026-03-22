variable "aws_region" {
  type        = string
  description = "AWS region where the Terraform state bucket will be created"
  default     = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket used as Terraform remote state backend"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the backend bucket"
  default = {
    ManagedBy = "Terraform"
    Purpose   = "terraform-backend"
  }
}
