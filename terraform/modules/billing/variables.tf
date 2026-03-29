variable "project_name" {
  description = "Project name used for budget naming"
  type        = string
}

variable "alert_email" {
  description = "Email address to receive budget and anomaly alerts"
  type        = string
}

variable "monthly_budget_amount" {
  description = "Monthly budget limit in USD"
  type        = number
}

