variable "name" {
  description = "Name prefix for ECR repositories (e.g. dataplatform-dev)"
  type        = string
}

variable "repositories" {
  description = "List of repository names to create under the name prefix"
  type        = list(string)
  default     = ["spark"]
}

variable "image_retention_count" {
  description = "Number of images to retain per repository"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
