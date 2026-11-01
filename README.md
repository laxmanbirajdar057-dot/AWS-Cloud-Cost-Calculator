# AWS Cloud Cost Monitoring & Budget Alert System

## 1. Project Overview

This project demonstrates how I built an automated AWS Cloud Cost Monitoring and Budget Alert System using Terraform and AWS managed services.

The solution monitors monthly AWS spending using AWS Budgets, sends email notifications through Amazon SNS when configured spending thresholds are crossed, and uses AWS Lambda with Cost Explorer to generate automated daily cost reports.

I also configured Amazon EventBridge to trigger the reporting function daily and Amazon CloudWatch to monitor estimated AWS billing charges.

## 2. AWS Architecture

![AWS Cloud Cost Monitoring Architecture](docs/images/architecture.png)

The architecture consists of two main workflows:

- **Budget monitoring:** AWS Budgets and CloudWatch send notifications through Amazon SNS.
- **Automated reporting:** EventBridge triggers Lambda, which retrieves cost data from Cost Explorer and publishes a report through SNS.

### Infrastructure Components

| AWS Service | Purpose |
|---|---|
| AWS Budgets | Monitors actual monthly spending against a $5 budget |
| Amazon SNS | Sends budget alerts and automated cost reports through email |
| Amazon CloudWatch | Monitors estimated AWS billing charges |
| AWS Lambda | Executes the Python cost reporting function |
| AWS Cost Explorer | Retrieves monthly spending and service-level cost data |
| Amazon EventBridge | Triggers the Lambda function every 24 hours |
| AWS IAM | Controls permissions between AWS services |
| Terraform | Provisions and manages infrastructure as Code |

## 3. Technologies Used

- **Cloud Platform:** Amazon Web Services (AWS)
- **Infrastructure as Code:** Terraform
- **Programming Language:** Python 3.12
- **Cost Management:** AWS Budgets, AWS Cost Explorer
- **Monitoring:** Amazon CloudWatch
- **Notifications:** Amazon SNS
- **Serverless Computing:** AWS Lambda
- **Scheduling:** Amazon EventBridge
- **Security:** AWS IAM
- **Operating System:** Ubuntu Linux
- **Version Control:** Git and GitHub

## 4. Terraform Project Structure

```text
AWS-Cloud-Cost-Calculator/
│
├── docs/
│   └── images/
│       ├── architecture.png
│       ├── budget-alert-workflow.png
│       ├── daily-report-workflow.png
│       └── terraform-workflow.png
│
├── lambda/
│   ├── cost_report.py
│   └── requirements.txt
│
├── scripts/
│   ├── cleanup.sh
│   └── deploy.sh
│
├── terraform/
│   ├── cloudwatch.tf
│   ├── lambda.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── sns.tf
│   ├── variables.tf
│   └── versions.tf
│
├── .github/
│   └── workflows/
│
├── .gitignore
└── README.md
```

Terraform configuration is separated into multiple files to keep AWS resource definitions organized and maintainable.

## 5. Budget Alert Workflow

![Budget Alert Workflow](docs/images/budget-alert-workflow.png)

I configured an AWS monthly budget of $5 with actual spending notification thresholds:

| Threshold | Spending |
|---|---:|
| 50% | $2.50 |
| 80% | $4.00 |
| 100% | $5.00 |

When actual spending crosses a configured threshold, AWS Budgets publishes a notification to Amazon SNS, which delivers an email alert to the subscribed address.

I also configured a CloudWatch billing alarm using the AWS/Billing EstimatedCharges metric.

## 6. Automated Cost Reporting Workflow

![Daily Cost Reporting Workflow](docs/images/daily-report-workflow.png)

I developed a Python-based AWS Lambda function that:

1. Retrieves current-month AWS cost data using Cost Explorer.
2. Calculates total monthly spending.
3. Calculates budget utilization.
4. Calculates the remaining budget.
5. Identifies the top three AWS services by cost.
6. Generates a formatted cost report.
7. Publishes the report to Amazon SNS for email delivery.

Amazon EventBridge invokes the Lambda function using a daily schedule (`rate(1 day)`).

### Sample Cost Report

```text
AWS MONTHLY COST REPORT
==============================

Report date: YYYY-MM-DD
Period: YYYY-MM-DD to YYYY-MM-DD

Total spending: $0.00
Monthly budget: $5.00
Budget utilization: 0.00%
Remaining budget: $5.00

TOP 3 EXPENSIVE AWS SERVICES
------------------------------
No service-level costs reported yet.

Generated automatically using AWS Lambda.
```

Actual cost values depend on AWS billing data availability and Cost Explorer reporting delays.

## 7. Terraform Infrastructure Workflow

![Terraform Workflow](docs/images/terraform-workflow.png)

I used Terraform to provision and manage the AWS infrastructure.

The deployment process follows these steps:

1. Initialize Terraform providers.
2. Format Terraform configuration files.
3. Validate the configuration.
4. Generate and review the execution plan.
5. Apply approved infrastructure changes.

Infrastructure changes are applied manually after reviewing the Terraform plan.

## 8. Deployment Instructions

### Prerequisites

- AWS account with the required service permissions.
- AWS CLI.
- Terraform 1.5 or later.
- Python 3.12.
- Git.

### Step 1: Clone the Repository

```bash
git clone https://github.com/laxmanbirajdar057-dot/AWS-Cloud-Cost-Calculator.git

cd AWS-Cloud-Cost-Calculator
```

### Step 2: Configure AWS CLI

```bash
aws configure
```

Verify your AWS identity:

```bash
aws sts get-caller-identity
```

### Step 3: Configure Terraform Variables

Navigate to the Terraform directory:

```bash
cd terraform
```

Create a local `terraform.tfvars` file using the variables defined in `variables.tf`.

Example:

```hcl
budget_amount      = 5
notification_email = "your-email@example.com"
```

Keep this file out of Git.

### Step 4: Initialize Terraform

```bash
terraform init
```

### Step 5: Format and Validate

```bash
terraform fmt -recursive
terraform validate
```

### Step 6: Review Infrastructure Changes

```bash
terraform plan
```

### Step 7: Deploy Infrastructure

After reviewing the proposed changes:

```bash
terraform apply
```

Confirm the deployment when prompted.

### Step 8: Package the Lambda Function

From the project root:

```bash
cd lambda
zip -j cost_report.zip cost_report.py
```

Return to the Terraform directory:

```bash
cd ../terraform
terraform plan
terraform apply
```

### Step 9: Test Lambda Execution

```bash
aws lambda invoke \
  --function-name aws-cost-report \
  --region ap-south-1 \
  response.json
```

Check the execution response:

```bash
cat response.json
```

### Step 10: View Lambda Logs

```bash
aws logs tail /aws/lambda/aws-cost-report \
  --region ap-south-1 \
  --since 10m
```

## 9. AWS Region Configuration

The project uses two AWS regions:

| Region | Purpose |
|---|---|
| ap-south-1 | Main infrastructure, Lambda and EventBridge |
| us-east-1 | Billing-related resources, Cost Explorer API and SNS topic |

## 10. Project Execution Evidence

Screenshots of actual AWS deployment and execution results can be added to `docs/screenshots/`.

Recommended evidence:

| Screenshot | Description |
|---|---|
| `terraform-apply.png` | Successful Terraform deployment |
| `aws-budget.png` | AWS monthly budget and thresholds |
| `sns-topic.png` | SNS topic and confirmed subscription |
| `cloudwatch-alarm.png` | Billing alarm configuration |
| `lambda-function.png` | Deployed Lambda function |
| `lambda-execution.png` | Successful Lambda invocation |
| `cost-report-email.png` | Received cost report email |
| `eventbridge-rule.png` | Enabled daily EventBridge schedule |

## 11. Security Practices

- Used IAM roles and service-specific permissions.
- Kept AWS credentials out of the Git repository.
- Excluded Terraform state files and sensitive variable files from version control.
- Used an email-confirmed SNS subscription.
- Reviewed Terraform plans before applying infrastructure changes.
- Configured CloudWatch log retention for Lambda execution logs.

## 12. Key Learnings and Future Improvements

Through this project, I gained practical experience with:

- AWS cost monitoring and budget management.
- Infrastructure provisioning using Terraform.
- IAM roles and AWS service permissions.
- Python-based serverless automation using Lambda.
- Event-driven scheduling with EventBridge.
- Monitoring and alerting using CloudWatch and SNS.
- Cost data retrieval and analysis using AWS Cost Explorer.

### Future Improvements

- Add GitHub Actions CI/CD for Terraform formatting and validation.
- Configure a secure remote Terraform backend.
- Add cost trend analysis and historical reporting.
- Build a dashboard for AWS spending visualization.
- Add approval-controlled infrastructure deployment.

---

**Project Type:** DevOps / Cloud / Infrastructure as Code  
**Purpose:** Hands-on AWS cloud cost monitoring, budget alerts and automated reporting.

**Author:** Laxman Birajdar

[GitHub Profile](https://github.com/laxmanbirajdar057-dot)