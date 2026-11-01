variable "budget_name" {
  description = "Name of the monthly AWS cost budget"
  type        = string
  default     = "aws-monthly-cost-budget"
}

variable "budget_amount" {
  description = "Monthly AWS spending limit in USD"
  type        = string
  default     = "5"
}

variable "notification_email" {
  description = "Email address for AWS budget notifications"
  type        = string
}