data "aws_caller_identity" "current" {
  provider = aws.billing
}

resource "aws_sns_topic" "cost_alerts" {
  provider = aws.billing

  name = "aws-cost-alerts"
}

resource "aws_sns_topic_policy" "cost_alerts_policy" {
  provider = aws.billing

  arn = aws_sns_topic.cost_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowAWSBudgetsToPublish"
        Effect = "Allow"

        Principal = {
          Service = "budgets.amazonaws.com"
        }

        Action = "sns:Publish"

        Resource = aws_sns_topic.cost_alerts.arn

        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "email_notification" {
  provider = aws.billing

  topic_arn = aws_sns_topic.cost_alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}