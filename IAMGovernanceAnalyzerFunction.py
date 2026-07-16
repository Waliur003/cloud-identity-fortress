import json
import os
import boto3
from datetime import datetime

# Initialize the AWS SDK clients outside the handler for warm-start efficiency
dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

# Pull target resources from environmental variables
TABLE_NAME = os.environ.get('TABLE_NAME', 'IdentityRisksTable')
TOPIC_ARN = os.environ.get('TOPIC_ARN')

def lambda_handler(event, context):
    """
    Evaluates incoming identity events from EventBridge, logs anomalies 
    to DynamoDB, and alerts SecOps teams via SNS.
    """
    print("Received raw event: " + json.dumps(event, indent=2))
    
    # Safely unpack EventBridge properties
    finding_id = event.get('id', 'N/A')
    timestamp = event.get('time', datetime.utcnow().isoformat())
    detail = event.get('detail', {})
    
    event_name = detail.get('eventName', 'UnknownEvent')
    event_source = detail.get('eventSource', 'UnknownSource')
    user_identity = detail.get('userIdentity', {})
    user_type = user_identity.get('type', 'UnknownUserType')
    actor_arn = user_identity.get('arn', 'N/A')
    
    # 🚨 Evaluate Security Risk Profiles
    risk_level = "LOW"
    risk_description = "Standard identity activity recorded."
    
    # Test 1: Check for Root account activity (Critical Severity)
    if user_type == "Root" or "root" in actor_arn.lower():
        risk_level = "CRITICAL"
        risk_description = "⚠️ CRITICAL: Root account activity or direct Root sign-in detected!"
        
    # Test 2: Check for Privileged/Risky IAM modifications (High Severity)
    elif event_name in [
        "CreateAccessKey", "CreateUser", "AttachUserPolicy", 
        "PutUserPolicy", "CreatePolicyVersion", "UpdateAccessKey"
    ]:
        risk_level = "HIGH"
        risk_description = f"🚨 HIGH RISK: Privileged identity boundary modification: {event_name} by {actor_arn}."

    # Test 3: Check for potential console bypass logins (Medium Severity)
    elif event_name == "ConsoleLogin" and user_type != "AssumedRole":
        risk_level = "MEDIUM"
        risk_description = f"🛡️ MEDIUM RISK: Direct IAM user console authentication parsed."

    # 1. Write the evaluation finding to the DynamoDB risk ledger
    try:
        table = dynamodb.Table(TABLE_NAME)
        table.put_item(
            Item={
                'FindingId': finding_id,
                'Timestamp': timestamp,
                'EventName': event_name,
                'EventSource': event_source,
                'UserType': user_type,
                'UserARN': actor_arn,
                'RiskLevel': risk_level,
                'Description': risk_description
            }
        )
        print(f"Recorded finding {finding_id} to database with risk rating: {risk_level}")
    except Exception as db_error:
        print(f"Database write failed: {str(db_error)}")

    # 2. Fire high-priority notifications using SNS
    if risk_level in ["HIGH", "CRITICAL"] and TOPIC_ARN:
        subject = f"[{risk_level}] Identity Fortress Intrusion Warning"
        message = (
            f"=== CLOUD IDENTITY FORTRESS REMEDIATION ALERT ===\n\n"
            f"An active identity risk has bypassed perimeter thresholds.\n\n"
            f"• Finding ID: {finding_id}\n"
            f"• Event Action: {event_name}\n"
            f"• Service Source: {event_source}\n"
            f"• Risk Level: {risk_level}\n"
            f"• Description: {risk_description}\n"
            f"• Threat Actor Identity: {user_type} ({actor_arn})\n"
            f"• Timestamp: {timestamp}\n\n"
            f"Action Required: Immediately audit active console sign-ins and investigate API credential usage."
        )
        try:
            sns.publish(
                TopicArn=TOPIC_ARN,
                Subject=subject,
                Message=message
            )
            print(f"Dispatched SNS alert for finding {finding_id}.")
        except Exception as sns_error:
            print(f"Failed to publish SNS broadcast: {str(sns_error)}")

    return {
        'statusCode': 200,
        'body': json.dumps('Security analysis completed successfully.')
    }