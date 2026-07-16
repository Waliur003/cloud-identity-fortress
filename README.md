# Cloud Security Engineering Project 07: Cloud Identity Fortress (Enterprise Identity Governance & Automated Threat Remediation)

## Overview

I have architected and deployed a multi-account IAM governance and identity security platform on AWS using automated serverless telemetry and active configuration auditing. This project establishes an automated detection and risk-classification engine that monitors enterprise identity mutations, captures privileged credential modifications, and alerts security operations teams within seconds of an anomaly. By substituting asynchronous, manual identity auditing practices with real-time event-driven parsers, the architecture reduces operational exposure and stops credential abuse before administrative privileges can be systematically exploited.

## The Problem

Modern enterprise environments depend on strict identity separation, but decentralized IAM practices introduce severe configuration risks:

* **Unmonitored Privilege Escalation:** Malicious actors or compromised roles often attempt to attach overly permissive administrative policies to existing identities, establishing persistence without triggering network security alerts.

* **Ambient Root Account Activity:** The root user account bypasses standard policy limitations. Any unmonitored use of root credentials indicates a critical security gap or active breach.

* **Lack of Historical Visibility:** Identity alterations and programmatic credential generations are frequently logged without being aggregated into a searchable risk index, leading to delayed post-incident forensics.

## The Solution

* **Continuous Logging Aggregation:** Activated AWS CloudTrail organization-wide to funnel global multi-region identity actions into an encrypted, centralized S3 logging bucket and a real-time CloudWatch Log Group.

* **Automated Event Filtration:** Configured Amazon EventBridge with custom pattern filters to immediately intercept root activity and high-risk IAM operations like user creations and policy modifications.

* **Serverless Risk Score Parsing:** Developed an AWS Lambda worker function in Python 3.12 to dynamically parse identity metadata, categorize threats based on risk profiles, and log incidents.

* **Decoupled Alerting and Auditing:** Engineered parallel response actions that record structured security findings into a serverless Amazon DynamoDB risk database while instantly broadcasting critical email alerts via Amazon SNS.

## Tech Stack

* **Identity Provider Hub:** AWS Organizations & IAM Identity Center (AWS SSO)

* **Threat Surveillance Engine:** AWS CloudTrail (Multi-Region Organization-wide configuration)

* **Log Aggregation Tier:** Amazon CloudWatch Logs & Amazon S3

* **Event Orchestration Broker:** Amazon EventBridge (Custom JSON pattern filtering)

* **Analytical Compute:** AWS Lambda (Python 3.12 Runtimes)

* **Risk Ledger Storage:** Amazon DynamoDB (On-Demand billing model)

* **SecOps Communication:** Amazon SNS (Standard topic email subscription)

* **Infrastructure as Code:** Terraform (v1.5+ Declarative Configuration Syntax)

## Architecture Diagram

## Project Procedure

### Multi-Account Identity Federation Setup

I initialized the organization control framework by deploying AWS Organizations across the environment. Inside the management account, I activated AWS IAM Identity Center and configured the default Identity Center directory to coordinate single sign-on parameters. To establish the administrative baseline for organizational personnel, I deployed a predefined permission set named EnterpriseAdminAccess configured with the AdministratorAccess corporate policy tree.

### Auditing and Surveillance Log Stream Configuration

I established account-wide surveillance by setting up a multi-region organizational trail in AWS CloudTrail named OrganizationIdentityTrail. I directed the trail to write encrypted, compressed log payloads into a dedicated S3 bucket named org-identity-fortress-audit-logs. Simultaneously, I configured log delivery to an Amazon CloudWatch Logs group named CloudTrail/IdentityFortressLogs, establishing an execution role to allow immediate transit of raw management events.

### Structured Database Ledger and Messaging Setup

I provisioned a serverless Amazon DynamoDB table named IdentityRisksTable. To track alerts chronologically without causing performance degradation, I defined FindingId as the partition key and Timestamp as the sort key, configuring the table capacity to On-Demand. Next, I deployed an Amazon SNS topic named IdentityAlertsTopic along with an email subscription mapped to a security operations inbox to manage immediate threat broadcasts.

### Serverless Risk Classification Development

I authored a Python 3.12 Lambda function named IAMGovernanceAnalyzerFunction to process incoming identity telemetry. The function dynamically checks for high-priority risks:

* **Root Activity:** Classifies all actions executed by the Root account as CRITICAL.

* **Privileged Mutations:** Categorizes operational API calls such as CreateUser, CreateAccessKey, and AttachUserPolicy as HIGH.

* **Console Authentication:** Logs standard interactive sign-ins as MEDIUM.

The worker function appends these classified records directly to the DynamoDB risk database and publishes urgent email notifications to the SNS alerts topic for all high-severity items.

### Decoupled Real-Time Trigger Rule Integration

I deployed an Amazon EventBridge rule named RouteIdentityThreats on the default account event bus. I configured a custom JSON pattern to filter out background noise and target IAM changes and root authentication. EventBridge was mapped to send matching payloads to the IAMGovernanceAnalyzerFunction, with target permissions configured to handle the invocations seamlessly.

## Infrastructure as Code (IaC) Architecture

To guarantee exact environment repeatability, prevent configuration drift, and eliminate manual console interaction, the complete active defense platform is codified using modular Terraform files.

## Directory Layout & Modular Structure

```text
cloud-identity-fortress/
├── provider.tf          # Configures AWS provider constraints and global resource tagging
├── variables.tf         # Abstracted input fields for region parameters and age limits
├── cloudtrail.tf        # Provisions CloudTrail tracking, S3 buckets, and CloudWatch streams
├── dynamodb.tf          # Configures the serverless threat storage tables and indexes
├── sns.tf               # Handles standard notification topics and email subscriptions
├── lambda.tf            # Deploys Python security workers with least-privilege IAM permissions
├── eventbridge.tf       # Formulates the event filters and targets execution mapping
└── outputs.tf           # Exports the live table IDs, rule targets, and configuration ARNs
```

## Detailed File-by-File Technical Breakdown

### System Provider Scoping (`provider.tf`)

Initializes the AWS cloud provider version constraints to ~> 5.0 and applies default tags globally across the resource inventory.

### Variable Abstractions (`variables.tf`)

Abstractly manages target deployment areas and sets default parameters to keep the infrastructure code base highly reusable.

### Central Log Storage (`cloudtrail.tf`)

Sets up the CloudTrail tracking engine, binds CloudWatch log delivery channels, and provisions S3 security log repositories.

### Threat Ledger Storage (`dynamodb.tf`)

Programmatically constructs the serverless threat log database table, defining the partition and sort keys for fast querying.

### Notification System (`sns.tf`)

Builds the standard SNS topic framework and links administrative email subscription targets.

### Serverless Execution Tier (`lambda.tf`)

Compresses the custom risk assessment code and builds the Python Lambda runtimes with isolated execution roles.

### Event Filtering Rules (`eventbridge.tf`)

Sets up the EventBridge filter rule with custom JSON queries and configures trigger execution targets.

### Output Definitions (`outputs.tf`)

Exports resource attributes like database names and function ARNs to simplify terminal verification.

## Verification and Results

### Multi-Account Directory Verification

**What this shows:** The AWS IAM Identity Center directory overview panel.

**Technical Proof:** Validates that the SSO managing instance is active in the region, uses the internal Identity Center directory, and is linked to the organizational hierarchy.

### Decoupled Event Ingestion Pipeline Configuration

**What this shows:** The EventBridge rule target page mapping to the compute tier.

**Technical Proof:** Proves that the RouteIdentityThreats rule actively intercepts target events and leverages automated permission structures to run the analyzer function.

### Real-Time Security Alert Broadcast

**What this shows:** An email notification delivered to the security inbox.

**Technical Proof:** Demonstrates that a test user creation action immediately generates an email alert containing the event name, risk level, actor details, and UTC timestamp, confirming the workflow executes at machine speed.

### Stateful Identity Risk Ledger Verification

**What this shows:** The items inventory of the DynamoDB database table.

**Technical Proof:** Verifies that multiple mock intrusion attempts are logged sequentially with structured partition keys, showing identical user actions recorded in the database.

## Verification Screenshots

### Multi-Account Identity Center Directory Configuration

This screenshot displays the AWS IAM Identity Center Management Console dashboard. It verifies that the SSO managing instance (ssoins-722335e386f975fd) is enabled in the US East (N. Virginia) region. It shows that the Identity source is set to the default Identity Center directory and mapped to the active organization ID (o-2n5fif32dd), proving that multi-account identity federation is operational.

### Decoupled EventBridge Target Ingestion Rule

This screenshot captures the Amazon EventBridge rule targets configuration page for the RouteIdentityThreats rule. It shows Target 1 pointing to the IAMGovernanceAnalyzerFunction, using the default execution role Amazon_EventBridge_Invoke_Lambda_1834673376 created specifically for this resource. This confirms that the event-driven trigger pipeline has the correct permissions to initiate serverless executions automatically.

### Real-Time Security Alert Broadcast (SNS Email Notification)

This screenshot displays an email notification with the subject line [HIGH] Identity Fortress Intrusion Warning. Sent by IdFortress (no-reply@sns.amazonaws.com) to the registered auditor inbox, the email details a high-risk event (CreateUser) initiated by the user SunWaliur (arn:aws:iam::418272769771:user/SunWaliur) at 2026-07-16T17:14:59Z. This proves that the automated detection and email alerting pipeline functions immediately upon threat ingestion.

### Stateful Identity Risk Ledger (DynamoDB Inventory)

This screenshot captures the Amazon DynamoDB items inventory page for the IdentityRisksTable. It shows two logged threat items returned from a database scan, indicating that two distinct CreateUser actions initiated by the user SunWaliur were recorded. The table successfully captures the unique FindingId partition keys, Timestamp sort keys, risk classification values, and detailed descriptions, proving that the threat ledger maintains a persistent audit trail.

## Future Improvements

* **Active Remediation Playbooks:** Extend the Lambda analyzer to automatically disable exposed access keys, isolate compromised IAM roles, or roll back unauthorized policy attachments in real-time.

* **Slack and ChatOps Integrations:** Route alerts to a designated team channel using an incoming webhook, allowing engineers to view and acknowledge threat events instantly.

* **Cross-Account Log Consolidation:** Configure the CloudTrail log group to aggregate events from separate development, staging, and production spoke accounts into a single, centralized security audit account.

## Notes

**Bottom Line:** The Cloud Identity Fortress project shifts IAM governance from passive compliance reporting to a real-time, event-driven protection pipeline. By aggregating global AWS Organizations identity logs, pattern-matching high-risk administrative alterations via EventBridge, and using serverless functions to parse threat data, this architecture logs identity risks to a DynamoDB ledger and sends email alerts in seconds. This provides complete governance over the identity perimeter and eliminates the visibility gaps common in modern cloud environments.