output "bucket_name" {
  description = "Name of the Terraform remote state bucket"
  value       = aws_s3_bucket.terraform_state.bucket
}
