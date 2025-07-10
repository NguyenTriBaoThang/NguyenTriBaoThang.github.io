---
title: "Cleaning Up Resources"
date: 2025-07-09
weight: 12
chapter: false
pre: "<b>12. </b>"
---

> **Objective**: Clean up all AWS resources of the serverless system (S3, Lambda, API Gateway, CloudFront, DynamoDB, SES, EventBridge, IAM) to avoid unnecessary costs after completing the deployment and testing of the student management website. Ensure all related resources are deleted, including DynamoDB tables, Lambda functions, S3 Buckets, API Gateway, CloudFront Distribution, SES identities, IAM Roles, and EventBridge Rule.

---

## Overview of Resource Cleanup

- **Purpose**: Delete resources created in sections 2.4, 3.1–3.3, 4.1–4.9, 5, 6.1–6.5, 7.1–7.3, 8.1–8.2 to ensure your AWS account does not incur costs after finishing the lab.
- **Resources to delete**:
  - **DynamoDB**: Table `studentData` (section 3).
  - **Lambda**: Functions `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail` (sections 3.1–3.3, 8.1).
  - **S3**: Buckets `student-management-website-2025`, `student-backup-20250706` (sections 2.4, 6.1–6.5).
  - **API Gateway**: API `student`, stage `prod`, `StudentApiKey`, `StudentUsagePlan` (sections 4.1–4.9).
  - **CloudFront**: Distribution `StudentWebsiteDistribution` (sections 7.1–7.3).
  - **SES**: Verified identities (`no-reply@studentapp.com`, `admin@studentapp.com`, `nguyentribaothang@gmail.com`) (section 3).
  - **IAM**: Roles `LambdaGetStudentRole`, `LambdaInsertStudentRole`, `DynamoDBBackupRoleStudent` (section 6.5).
  - **EventBridge**: Rule `DailyDynamoDBBackup` (section 8.2).

---

## Prerequisites

{{% notice info %}}
Make sure you have completed sections 2.4, 3.1–3.3, 4.1–4.9, 5, 6.1–6.5, 7.1–7.3, 8.1–8.2 and tested the results (section 9). Your AWS account needs permissions:
- `dynamodb:DeleteTable`
- `lambda:DeleteFunction`
- `s3:DeleteBucket`, `s3:DeleteObject`
- `apigateway:DELETE`
- `cloudfront:UpdateDistribution`, `cloudfront:DeleteDistribution`
- `ses:DeleteIdentity`
- `iam:DeleteRole`
- `events:DeleteRule`, `events:RemoveTargets`
AWS Region: `us-east-1`.
{{% /notice %}}

---

## Detailed Steps

1. **Delete DynamoDB Table studentData**
   - In **AWS Management Console**, go to **DynamoDB > Tables > studentData**.
   - Click **Actions > Delete table**.
   - Enter `Confirm`, click **Delete**.
   - **Expected result**: The `studentData` table is no longer listed.
   - **Troubleshooting**: If the table is in use (e.g., by Lambda), check CloudWatch logs (section 10) and ensure no functions are accessing it.
     ![Delete DynamoDB table.](/images/12-cleaning-up-resources/cleaning-up-resources-01.png)
     *Figure 1: Delete DynamoDB table.*

2. **Delete Lambda Functions**
   - In **AWS Management Console**, go to **Lambda > Functions**.
   - Select each function: `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`.
   - Click **Actions > Delete function**, type `delete`, click **Delete**.
   - **Expected result**: The functions are no longer listed.
   - **Troubleshooting**: If the function is attached to a trigger (e.g., API Gateway), remove the trigger first (step 4).
     ![Delete Lambda functions.](/images/12-cleaning-up-resources/cleaning-up-resources-02.png)
     *Figure 5: Delete Lambda functions.*

3. **Delete S3 Buckets**
   - In **AWS Management Console**, go to **S3 > Buckets**.
   - For each bucket (`student-management-website-2025`, `student-backup-20250706`):
     - Select the bucket, click **Empty**, type `permanently delete`, click **Empty**.
     - After deleting all objects, select the bucket, click **Delete**, enter the bucket name, click **Delete bucket**.
   - **Expected result**: Buckets are no longer listed.
   - **Troubleshooting**: If the bucket cannot be deleted, check `s3:DeleteBucket`, `s3:DeleteObject` permissions or remaining objects.
     ![Delete S3 buckets.](/images/12-cleaning-up-resources/cleaning-up-resources-03.png)
     *Figure 6: Delete S3 buckets.*

4. **Delete API Gateway student**
   - In **AWS Management Console**, go to **API Gateway > APIs > student**.
   - Click **API Actions > Delete API**, enter `confirm`, click **Delete**.
   - **Expected result**: The `student` API (including stage `prod`, `StudentApiKey`, `StudentUsagePlan`) is no longer listed.
   - **Troubleshooting**: If the API is in use, check CloudFront or CloudWatch logs (section 10).
     ![Delete API Gateway.](/images/12-cleaning-up-resources/cleaning-up-resources-04.png)
     *Figure 7: Delete API Gateway.*
     ![Confirm API deletion.](/images/12-cleaning-up-resources/cleaning-up-resources-05.png)
     *Figure 8: Confirm API deletion.*
     ![API deleted.](/images/12-cleaning-up-resources/cleaning-up-resources-06.png)
     *Figure 9: API deleted.*
     ![Delete API Gateway.](/images/12-cleaning-up-resources/cleaning-up-resources-07.png)
     *Figure 7: Delete API Gateway.*
     ![Confirm API deletion.](/images/12-cleaning-up-resources/cleaning-up-resources-08.png)
     *Figure 8: Confirm API deletion.*
     ![API deleted.](/images/12-cleaning-up-resources/cleaning-up-resources-09.png)
     *Figure 9: API deleted.*

5. **Delete CloudFront Distribution**
   - In **AWS Management Console**, go to **CloudFront > Distributions > StudentWebsiteDistribution**.
   - Click **Disable**, wait for the status to become **Disabled** (5–15 minutes).
   - Select the **Distribution**, click **Delete**, confirm **Yes, Delete**.
   - **Expected result**: The distribution is no longer listed.
   - **Troubleshooting**: If you cannot disable, check `cloudfront:UpdateDistribution`, `cloudfront:DeleteDistribution` permissions.
     ![Delete CloudFront Distribution.](/images/12-cleaning-up-resources/cleaning-up-resources-10.png)
     *Figure 10: Delete CloudFront Distribution.*

6. **Delete SES Verified Identities**
   - In **AWS Management Console**, go to **SES > Verified identities**.
   - Select emails: `nguyentribaothang@gmail.com`, `no-reply@studentapp.com`, `admin@studentapp.com` (if present), click **Delete identity**.
   - **Expected result**: The emails are no longer listed.
   - **Troubleshooting**: If the email is in use, check if Lambda `insertStudentData` or `DynamoDBBackup` has been deleted (step 2).
     ![Delete SES identities.](/images/12-cleaning-up-resources/cleaning-up-resources-11.png)
     *Figure 11: Delete SES identities.*

7. **Delete IAM Roles**
   - In **AWS Management Console**, go to **IAM > Roles**.
   - Select each role: `LambdaGetStudentRole`, `LambdaInsertStudentRole`, `DynamoDBBackupRoleStudent`, click **Delete role**, confirm.
   - **Expected result**: The roles are no longer listed.
   - **Troubleshooting**: If the role is in use, ensure Lambda functions and API Gateway have been deleted.
     ![Delete IAM roles.](/images/12-cleaning-up-resources/cleaning-up-resources-12.png)
     *Figure 12: Delete IAM roles.*

8. **Delete EventBridge Rule**
   - In **AWS Management Console**, go to **EventBridge > Rules > DailyDynamoDBBackup**.
   - Click **Delete**, confirm in the pop-up.
   - **Expected result**: The `DailyDynamoDBBackup` rule is no longer listed.
   - **Troubleshooting**: If the rule cannot be deleted, check `events:DeleteRule`, `events:RemoveTargets` permissions or ensure Lambda `BackupDynamoDBAndSendEmail` has been deleted.
     ![Delete EventBridge Rule.](/images/12-cleaning-up-resources/cleaning-up-resources-13.png)
     *Figure 13: Delete EventBridge Rule.*

---

## Conclusion

All AWS resources (`studentData`, Lambda functions, S3 Buckets, `student` API, CloudFront `StudentWebsiteDistribution`, SES identities, IAM Roles, EventBridge Rule) have been deleted, ensuring no further costs are incurred. The serverless system has been completely cleaned up.

> **Next step**: Check the AWS Billing Dashboard to verify there are no remaining charges or start deploying a new