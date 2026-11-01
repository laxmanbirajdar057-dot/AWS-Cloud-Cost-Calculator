


resource "aws_budgets_budget" "monthly_cost" {


  depends_on = [
    aws_sns_topic_policy.cost_alerts_policy
  ]
  provider = aws.billing

  name         = var.budget_name
  budget_type  = "COST"
  limit_amount = var.budget_amount
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # Alert at 50% of budget
  notification {
    comparison_operator = "GREATER_THAN"
    threshold           = 50
    threshold_type      = "PERCENTAGE"
    notification_type   = "ACTUAL"
    subscriber_sns_topic_arns = [
      aws_sns_topic.cost_alerts.arn
    ]
  }

  # Alert at 80% of budget
  notification {
    comparison_operator = "GREATER_THAN"
    threshold           = 80
    threshold_type      = "PERCENTAGE"
    notification_type   = "ACTUAL"
    subscriber_sns_topic_arns = [
      aws_sns_topic.cost_alerts.arn
    ]
  }

  # Alert at 100% of budget
  notification {
    comparison_operator = "GREATER_THAN"
    threshold           = 100
    threshold_type      = "PERCENTAGE"
    notification_type   = "ACTUAL"
    subscriber_sns_topic_arns = [
      aws_sns_topic.cost_alerts.arn
    ]
  }
}
