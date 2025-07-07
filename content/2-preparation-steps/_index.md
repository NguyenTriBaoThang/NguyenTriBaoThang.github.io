---
title: "Preparation Steps"
date: 2023-10-25
weight: 2
chapter: false
pre: "<b>2. </b>"
---

> **Objective**: Set up the necessary environment to deploy a serverless application for managing student information, including an AWS account, IAM roles, a DynamoDB table, and the SES service.

To begin the **Deploying a Serverless Website for Managing Student Information with AWS** workshop, you need to prepare the basic components to ensure smooth integration with AWS services such as Lambda, DynamoDB, API Gateway, S3, CloudFront, and SES.

---

## Initial Requirements

{{% notice info %}}
You need an **AWS account** to perform the steps in this workshop. If you don't have one, please create an account before proceeding.
{{% /notice %}}

To learn how to create an AWS account, refer to the detailed guide here:  
- [How to Create an AWS Account](https://000001.awsstudygroup.com/)

---

## Preparation Steps

Below are the specific steps to prepare the environment for the serverless application:

| **Step** | **Content** | **Description** |
|----------|-------------|-----------------|
| 2.1 | [Create IAM Role for Lambda Get](/2-preparation-steps/2.1-create-iam-role-for-lambda-get/) | Create an IAM role for the Lambda function to handle retrieving student data from DynamoDB, ensuring secure and minimal access. |
| 2.2 | [Create IAM Role for Lambda Post](/2-preparation-steps/2.2-create-iam-role-for-lambda-post/) | Create an IAM role for the Lambda function to handle storing student data in DynamoDB, adhering to the principle of least privilege. |
| 2.3 | [Create IAM Role for DynamoDB Backup](/2-preparation-steps/2.3-create-iam-role-for-dynamodb-backup/) | Create an IAM role for the Lambda function to back up data from DynamoDB to S3, including permissions to write to S3 and send emails via SES. |
| 2.4 | [Create Table in DynamoDB](/2-preparation-steps/2.4-createtable-in-dynamodb/) | Set up the `studentData` table with `studentid` (String) as the primary key to store student information (Student ID, Full Name, Class, Date of Birth, Email). |
| 2.5 | [Configure SES](/2-preparation-steps/2.5-configureses/) | Configure AWS SES to send confirmation emails when saving data and backup notifications with a pre-signed URL. |

> **Note**: Follow the steps in order to ensure the environment is set up correctly. Each step will be detailed in the corresponding documents.

---

## Conclusion

After completing these preparation steps, you will have:  
- A ready **AWS account** to deploy the application.  
- The **IAM Roles** configured to ensure security and minimal access.  
- The **studentData** table in DynamoDB to store student data.  
- The **SES** service set up to send email notifications.

> **Ready to continue?**  
> Proceed to [Create IAM Role for Lambda Get](/2-preparation-steps/2.1-create-iam-role-for-lambda-get/) to start setting up the IAM role for the first Lambda function!
