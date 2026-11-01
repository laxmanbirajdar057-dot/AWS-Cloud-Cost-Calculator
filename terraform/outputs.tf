output "budget_name" {
  description = "Name of the AWS monthly budget"
  value       = aws_budgets_budget.monthly_cost.name
}

output "budget_limit" {
  description = "Monthly AWS budget limit"
  value       = aws_budgets_budget.monthly_cost.limit_amount
}

output "budget_time_unit" {
  description = "Budget monitoring period"
  value       = aws_budgets_budget.monthly_cost.time_unit
}

output "sns_topic_arn" {
  description = "SNS topic ARN for AWS cost alerts"
  value       = aws_sns_topic.cost_alerts.arn
}

output "cloudwatch_alarm_name" {
  description = "CloudWatch billing alarm name"
  value       = aws_cloudwatch_metric_alarm.billing_alarm.alarm_name
}

output "lambda_function_name" {
  description = "AWS Lambda cost reporting function"
  value       = aws_lambda_function.cost_report.function_name
}

output "lambda_log_group" {
  description = "CloudWatch log group for Lambda"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

output "eventbridge_schedule" {
  description = "Daily cost report schedule"
  value       = aws_cloudwatch_event_rule.daily_cost_report.schedule_expression
}