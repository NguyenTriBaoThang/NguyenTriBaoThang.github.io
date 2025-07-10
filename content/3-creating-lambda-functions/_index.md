---
title: "Creating Lambda Functions"
date: 2025-07-09
weight: 3
chapter: false
pre: "<b> 3. </b>"
---

> **Objective**: Create and configure three Lambda functions in AWS to support the main features of the student information management system:  
> - `getStudentData`: Retrieve all student data from the DynamoDB `studentData` table.  
> - `insertStudentData`: Store student information in the DynamoDB table and send a confirmation email via SES.  
> - `BackupDynamoDBAndSendEmail`: Backup data from the DynamoDB table to S3 and send a notification email with a backup file download link.  

Each function will be created through the AWS Management Console, using the programming language **Python 3.12** (or the latest supported version), assigned the corresponding IAM Role (created in sections 2.1, 2.2, 2.3), and configured to integrate with other AWS services (DynamoDB, SES, S3). The steps below ensure that learners can deploy the functions easily while optimizing performance and security.

---

## Initial Requirements

{{% notice info %}}
You need to complete the preparation steps in section 2 (IAM Roles, DynamoDB table, SES) before creating the Lambda functions. Ensure your AWS account is ready.
{{% /notice %}}

---

## Configuration Steps

Below are the specific steps to configure the Lambda functions:

| **Step** | **Content** | **Description** |
|----------|-------------|-----------------|
| 3.1 | [Create the getStudentData Function](./3.1-create-the-getstudentdata-function/) | Create the Lambda function to retrieve all student data from the DynamoDB `studentData` table using the Scan operation. |
| 3.2 | [Create the insertStudentData Function](./3.2-create-the-insertstudentdata-function/) | Create the Lambda function to store student information in the DynamoDB `studentData` table and send a confirmation email via SES. |
| 3.3 | [Create the BackupDynamoDBAndSendEmail Function](./3.3-create-the-backupdynamodbandsendemail-function/) | Create the Lambda function to back up data from the DynamoDB `studentData` table to S3 and send a notification email with a pre-signed URL. |

> **Note**: Follow the steps in order to ensure that the functions are configured correctly. Each step will be detailed in the corresponding documents.

---

## Conclusion

After completing these configuration steps, you will have:  
- The **getStudentData** function to retrieve student data.  
- The **insertStudentData** function to store data and send a confirmation email.  
- The **BackupDynamoDBAndSendEmail** function to back up data and send notifications.  

> **Ready to continue?**  
> Go to [Create the getStudentData Function](./3.1-create-the-getstudentdata-function/) to start configuring the first Lambda function!
