variable "aws_region" {
  description = "AWS region for the application infrastructure"
  type        = string
  default     = "ap-south-1"
}

variable "image_uri" {
  description = "Full ECR image URI including image tag"
  type        = string
}
