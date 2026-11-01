# Lambda execution role
resource "aws_iam_role" "lambda_role" {

  name = "aws-cost-report-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "lambda.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

# Lambda permissions
resource "aws_iam_role_policy" "lambda_permissions" {

  name = "aws-cost-report-permissions"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ce:GetCostAndUsage"
        ]

        Resource = "*"
      },
      {
        Effect = "Allow"

        Action = [
          "sns:Publish"
        ]

        Resource = aws_sns_topic.cost_alerts.arn
      },
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "${aws_cloudwatch_log_group.lambda_logs.arn}:*"
      }
    ]
  })
}

# Lambda CloudWatch log group
resource "aws_cloudwatch_log_group" "lambda_logs" {

  name              = "/aws/lambda/aws-cost-report"
  retention_in_days = 14
}

# Lambda function
resource "aws_lambda_function" "cost_report" {

  function_name = "aws-cost-report"
  role          = aws_iam_role.lambda_role.arn

  runtime = "python3.12"
  handler = "cost_report.lambda_handler"

  filename         = "../lambda/cost_report.zip"
  source_code_hash = filebase64sha256("../lambda/cost_report.zip")

  timeout     = 30
  memory_size = 128

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.cost_alerts.arn
      BUDGET_LIMIT  = var.budget_amount
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda_permissions,
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_cloudwatch_log_group.lambda_logs
  ]
}

# Daily report schedule
resource "aws_cloudwatch_event_rule" "daily_cost_report" {

  name                = "aws-daily-cost-report"
  description         = "Trigger AWS cost report daily"
  schedule_expression = "rate(1 day)"
}

# Connect EventBridge to Lambda
resource "aws_cloudwatch_event_target" "lambda_target" {

  rule = aws_cloudwatch_event_rule.daily_cost_report.name
  arn  = aws_lambda_function.cost_report.arn
}

# Allow EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {

  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_report.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_cost_report.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role = aws_iam_role.lambda_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
