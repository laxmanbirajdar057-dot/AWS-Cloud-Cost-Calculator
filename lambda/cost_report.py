import os
import boto3
from datetime import date, timedelta


def lambda_handler(event, context):

    # AWS configuration
    sns_topic_arn = os.environ["SNS_TOPIC_ARN"]
    budget_limit = float(os.environ.get("BUDGET_LIMIT", "5"))

    # Cost Explorer runs through us-east-1
    ce = boto3.client("ce", region_name="us-east-1")

    # SNS topic is also located in us-east-1
    sns = boto3.client("sns", region_name="us-east-1")

    # Current month date range
    today = date.today()
    start_date = today.replace(day=1)
    end_date = today + timedelta(days=1)

    response = ce.get_cost_and_usage(
        TimePeriod={
            "Start": start_date.isoformat(),
            "End": end_date.isoformat()
        },
        Granularity="MONTHLY",
        Metrics=["UnblendedCost"],
        GroupBy=[
            {
                "Type": "DIMENSION",
                "Key": "SERVICE"
            }
        ]
    )

    # Calculate total spending
    results = response["ResultsByTime"]

    total_cost = 0.0
    service_costs = []

    for period in results:

        total_cost += float(
            period["Total"]["UnblendedCost"]["Amount"]
        )

        for group in period.get("Groups", []):

            service_name = group["Keys"][0]

            amount = float(
                group["Metrics"]["UnblendedCost"]["Amount"]
            )

            if amount > 0:
                service_costs.append(
                    (service_name, amount)
                )

    # Sort services by spending
    service_costs.sort(
        key=lambda item: item[1],
        reverse=True
    )

    remaining_budget = budget_limit - total_cost

    utilization = (
        (total_cost / budget_limit) * 100
        if budget_limit > 0 else 0
    )

    # Generate report
    report = [
        "AWS MONTHLY COST REPORT",
        "=" * 30,
        f"Report date: {today}",
        f"Period: {start_date} to {today}",
        f"Total spending: ${total_cost:.2f}",
        f"Monthly budget: ${budget_limit:.2f}",
        f"Budget utilization: {utilization:.2f}%",
        f"Remaining budget: ${remaining_budget:.2f}",
        "",
        "TOP 3 EXPENSIVE AWS SERVICES",
        "-" * 30
    ]

    for service, amount in service_costs[:3]:
        report.append(
            f"{service}: ${amount:.2f}"
        )

    if not service_costs:
        report.append("No service-level costs reported yet.")

    report.append("")
    report.append("Generated automatically using AWS Lambda.")

    message = "\n".join(report)

    # Send report through SNS
    sns.publish(
        TopicArn=sns_topic_arn,
        Subject="AWS Monthly Cost Report",
        Message=message
    )

    print(message)

    return {
        "statusCode": 200,
        "body": "AWS cost report generated and published successfully."
    }