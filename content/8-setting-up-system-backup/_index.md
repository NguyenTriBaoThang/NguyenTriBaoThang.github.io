---
title: "Setting Up Automated System Backup"
date: 2025-07-09
weight: 8
chapter: false
pre: "<b>8. </b>"
---

> **Objective**: Set up an automated backup system for the DynamoDB table `studentData` by modifying the Lambda function `BackupDynamoDBAndSendEmail` (integrated with the **POST /backup** endpoint, section 4.8) and creating an Amazon EventBridge Rule to trigger scheduled backups. The backup will save data to the S3 Bucket `student-backup-20250706` (section 6.5) and send notification emails via Amazon SES. The system ensures:  
> - Automation of the backup process to minimize manual intervention.  
> - Integration with the web interface (distributed via CloudFront, sections 7.1–7.3) and the `student` API (stage `prod`, section 4.8).  
> - Security with `StudentApiKey` (section 4.2) and IAM role `DynamoDBBackupRole` (section 6.5).

---

## Prerequisites

{{% notice info %}}
You need to complete sections 7.1–7.3 (create and configure CloudFront `StudentWebsiteDistribution`), 6.1–6.5 (configure S3 Buckets `student-management-website-2025` and `student-backup-20250706`), 5 (build the web interface), 4.1–4.9 (create and deploy the `student` API, `StudentApiKey`, `StudentUsagePlan`, endpoints **GET /students**, **POST /students**, **POST /backup**, CORS, stage `prod`), 3.3 (create the Lambda function `BackupDynamoDBAndSendEmail` with the role `DynamoDBBackupRole`), and 3 (create the DynamoDB table `studentData`, verify SES email). Ensure your AWS account has permissions for `lambda:UpdateFunctionConfiguration`, `events:PutRule`, `events:PutTargets`, `iam:PassRole`, and the AWS region is `us-east-1`.
{{% /notice %}}

---

## Configuration Steps

Below are the specific steps to set up automated backup:

| **Step** | **Content** | **Description** |
|----------|-------------|-----------------|
| 8.1 | [Modify Lambda Backup Configuration](/8-automatic-backup/8.1-configuring-lambda-backup/) | Update the Lambda function `BackupDynamoDBAndSendEmail` to support triggering from EventBridge, ensuring data from DynamoDB `studentData` is saved to S3 `student-backup-20250706` and email is sent via SES. |
| 8.2 | [Create EventBridge Rule for Automated Backup](/8-automatic-backup/8.2-creating-eventbridge-rule/) | Create an Amazon EventBridge Rule `StudentDataBackupRule` to trigger the Lambda function `BackupDynamoDBAndSendEmail` on a schedule (e.g., daily). |

> **Note**: Follow the steps in order to ensure the automated backup is configured correctly. Each step is detailed in the corresponding documentation.

---

## Conclusion

By completing these configuration steps, you will have:  
- The Lambda function `BackupDynamoDBAndSendEmail` updated to support both API Gateway and EventBridge triggers.  
- The EventBridge Rule `StudentDataBackupRule` triggering scheduled backups, saving data from DynamoDB `studentData` to S3 `student-backup-20250706` with SES notifications.  
- A fully integrated system with the `student` API (stage `prod`) and the web interface via CloudFront `StudentWebsiteDistribution`.

> **Ready to continue?**  
> Go to [Modify Lambda Backup Configuration](/8-automatic-backup/8.1-configuring-lambda-backup/) to start configuring