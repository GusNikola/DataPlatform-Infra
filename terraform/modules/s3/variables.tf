variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable S3 versioning"
  type        = bool
  default     = false
}

variable "ia_transition_days" {
  description = "Days before transitioning objects to Standard-IA"
  type        = number
  default     = 30
}

variable "airflow_logs_expiry_days" {
  description = "Days before expiring Airflow task logs"
  type        = number
  default     = 30
}

variable "spark_eventlogs_expiry_days" {
  description = "Days before expiring Spark event logs"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
