resource "aws_cloudwatch_metric_alarm" "billing_alarm" {

  provider = aws.billing

  alarm_name        = "aws-monthly-cost-alarm"
  alarm_description = "Alert when estimated AWS account charges reach $5"

  comparison_operator = "GreaterThanOrEqualToThreshold"

  evaluation_periods = 1
  period             = 21600
  statistic          = "Maximum"

  metric_name = "EstimatedCharges"
  namespace   = "AWS/Billing"

  threshold = 5

  dimensions = {
    Currency = "USD"
  }

  alarm_actions = [
    aws_sns_topic.cost_alerts.arn
  ]

  treat_missing_data = "notBreaching"
}