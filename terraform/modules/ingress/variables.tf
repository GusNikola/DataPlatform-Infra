# Input variables for the ingress-nginx module.

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
