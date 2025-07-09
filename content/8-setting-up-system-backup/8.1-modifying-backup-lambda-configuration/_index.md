---
title: "Modify Lambda Backup Configuration"
date: 2023-10-25
weight: 1
chapter: false
pre: "<b>8.1. </b>"
---

> **Objective**: Update the configuration for the Lambda function `BackupDynamoDBAndSendEmail` (created in section 3.3, integrated with the **POST /backup** endpoint, section 4.6) to ensure efficient operation when backing up data from the DynamoDB table `studentData` to the S3 Bucket `student-backup-20250706` (section 6.5) and sending notification emails via Amazon SES. The configuration includes Memory, Ephemeral Storage, Execution Role, and Environment Variables to optimize performance and integrate with the serverless system.

---

## Overview of Lambda Backup

- **Role of Lambda `BackupDynamoDBAndSendEmail`**:  
  - Handles the **POST /backup** endpoint in the `student` API (stage `prod`, section 4.8), reads data from DynamoDB `studentData`, saves a JSON file to S3 `student-backup-20250706`, and sends a notification email via SES.  
  - Updated to support triggering from both API Gateway and Amazon EventBridge (section 8.2) for manual backup (via web interface) and automatic backup (via schedule).  
- **System Integration**:  
  - The web interface (distributed via CloudFront `StudentWebsiteDistribution`, sections 7.1–7.3) from S3 Bucket `student-management-website-2025` (sections 6.1–6.4) calls the `student` API with **Invoke URL** (e.g., `https://abc123.execute-api.us-east-1.amazonaws.com/prod`) and `StudentApiKey` (section 4.2).  
  - Functions:  
    - **POST /students**: Save records to DynamoDB `studentData` and send email via SES.  
    - **GET /students**: Display data in a table.  
    - **POST /backup**: Create a JSON file in `student-backup-20250706` and send a notification email.  
  - CORS is configured (section 4.7) to support requests from the CloudFront domain (e.g., `https://d12345678.cloudfront.net`).  
  - IAM role `DynamoDBBackupRole` (section 6.5) grants access to DynamoDB, S3, and SES.

---

## Prerequisites

{{% notice info %}}
You need to complete the following:  
- Section 2.4: Create S3 Bucket `student-backup-20250706`.  
- Section 3.3: Create Lambda function `BackupDynamoDBAndSendEmail` with role `DynamoDBBackupRole`.  
- Sections 4.1–4.9: Create and configure the `student` API, including `StudentApiKey`, `StudentUsagePlan`, **GET /students**, **POST /students**, **POST /backup** methods, enable CORS, and deploy the `prod` stage.  
- Section 5: Build the web interface with `index.html`, `styles.css`, `scripts.js`.  
- Sections 6.1–6.5: Create and configure S3 Buckets `student-management-website-2025` and `student-backup-20250706`.  
- Sections 7.1–7.3: Create and configure CloudFront `StudentWebsiteDistribution`.  
Ensure your AWS account has permissions for `lambda:UpdateFunctionConfiguration`, `lambda:GetFunction`, `s3:PutObject`, `dynamodb:Scan`, `ses:SendEmail`, and the AWS region is `us-east-1`.
{{% /notice %}}

---

## Detailed Actions

1. **Access AWS Management Console and Lambda**  
   - Log in to **[AWS Management Console](https://console.aws.amazon.com)**.  
   - In the search bar, enter **Lambda** and select **AWS Lambda**.  
   - Verify AWS region: `us-east-1` to synchronize with DynamoDB `studentData`, S3 (`student-management-website-2025`, `student-backup-20250706`), API Gateway, SES, and CloudFront.  
     ![AWS Console interface with Lambda search bar.](/images/8-setting-up-system-backup/8.1-modifying-backup-lambda-configuration/modifying-backup-lambda-configuration-01.png)
     *Figure 1: AWS Console interface with Lambda search bar.*

2. **Select Functions List**  
   - In **Lambda > Functions**, view the list of Lambda functions.  
   - Check: Ensure the function `BackupDynamoDBAndSendEmail` (section 3.3) appears.  
   - **Troubleshooting**: If not found, verify the function name and `lambda:GetFunction` permission:  
     ```json
     {
         "Version": "2012-10-17",
         "Statement": [
             {
                 "Effect": "Allow",
                 "Action": "lambda:GetFunction",
                 "Resource": "arn:aws:lambda:us-east-1:<AWS_ACCOUNT_ID>:function:BackupDynamoDBAndSendEmail"
             }
         ]
     }
     ```
     Replace `<AWS_ACCOUNT_ID>` with your AWS account ID.  
     ![Lambda Functions list.](/images/8-setting-up-system-backup/8.1-modifying-backup-lambda-configuration/modifying-backup-lambda-configuration-02.png)
     *Figure 2: Lambda Functions list.*

3. **Select the Backup Lambda Function**  
   - Click on `BackupDynamoDBAndSendEmail` to enter the details page.  
   - **Identification**: The function is linked to the **POST /backup** endpoint (section 4.6) and the `DynamoDBBackupRole` (section 6.5).  
     ![Lambda function details interface.](/images/8-setting-up-system-backup/8.1-modifying-backup-lambda-configuration/modifying-backup-lambda-configuration-03.png)
     *Figure 3: Lambda function details interface.*

4. **Access the Configuration Tab**  
   - In the details page, select the **Configuration** tab (next to **Code**, **Test**).

5. **Update General Configuration**  
   - In **Configuration > General configuration**, click **Edit**.  
   - Configure:  
     - **Memory**: 128 MB (sufficient for reading DynamoDB, writing to S3, sending SES email; increase if needed but consider cost).  
     - **Ephemeral Storage**: 512 MB (default, enough for temporary data).  
     - **Execution Role**: Select **Use an existing role**, choose `DynamoDBBackupRole`.  
       - Verify permissions:  
         ```json
         {
             "Version": "2012-10-17",
             "Statement": [
                 {
                     "Effect": "Allow",
                     "Action": [
                         "dynamodb:Scan",
                         "s3:PutObject",
                         "ses:SendEmail"
                     ],
                     "Resource": [
                         "arn:aws:dynamodb:us-east-1:<AWS_ACCOUNT_ID>:table/studentData",
                         "arn:aws:s3:::student-backup-20250706/*",
                         "arn:aws:ses:us-east-1:<AWS_ACCOUNT_ID>:identity/*"
                     ]
                 }
             ]
         }
         ```
         Replace `<AWS_ACCOUNT_ID>` with your AWS account ID.  
   - Click **Save**.  
   - **Troubleshooting**:  
     - Role not listed: Check `DynamoDBBackupRole` (section 6.5) and `iam:PassRole` permission.  
     - Permission error: Ensure the ARNs for `studentData`, `student-backup-20250706`, and SES identity are correct.  
     ![Update General configuration.](/images/8-setting-up-system-backup/8.1-modifying-backup-lambda-configuration/modifying-backup-lambda-configuration-04.png)
     *Figure 4: Update General configuration.*

6. **Save Configuration**  
   - Click **Save**.  
   - Result: Notification _"Successfully updated function configuration"_. Memory (128 MB), Ephemeral Storage (512 MB), and Execution Role (`DynamoDBBackupRole`) are updated.  
   - **Troubleshooting**:  
     - **AccessDenied**: Check `lambda:UpdateFunctionConfiguration` permission:  
       ```json
       {
           "Version": "2012-10-17",
           "Statement": [
               {
                   "Effect": "Allow",
                   "Action": "lambda:UpdateFunctionConfiguration",
                   "Resource": "arn:aws:lambda:us-east-1:<AWS_ACCOUNT_ID>:function:BackupDynamoDBAndSendEmail"
               }
           ]
       }
       ```
     - Configuration not saved: Check input values and `DynamoDBBackupRole`.  
     ![Save configuration success notification.](/images/8-setting-up-system-backup/8.1-modifying-backup-lambda-configuration/modifying-backup-lambda-configuration-06.png)
     *Figure 5: Save configuration success notification.*

7. **Create Environment Variables**  
   - In **Configuration > Environment variables**, click **Edit**.  
   - Add variables:  
     - **Key**: `S3_BUCKET_NAME`, **Value**: `student-backup-20250706` (target bucket for backup JSON).  
     - **Key**: `SENDER_EMAIL`, **Value**: `no-reply@studentapp.com` (SES verified email).  
     - **Key**: `RECIPIENT_EMAIL`, **Value**: `admin@studentapp.com` (SES verified email).  
   - Click **Save**.  
   - **Reason**: Environment variables allow the Lambda code to reference bucket and email dynamically, avoiding hardcoding.  
   - **Troubleshooting**:  
     - Save error: Check `lambda:UpdateFunctionConfiguration` permission.  
     - Bucket does not exist: Verify `student-backup-20250706` (section 2.4).  
     - Invalid email: Verify `no-reply@studentapp.com` and `admin@studentapp.com` in SES (section 3).  
     ![Add Environment variables.](/images/8-setting-up-system-backup/8.1-modifying-backup-lambda-configuration/modifying-backup-lambda-configuration-07.png)
     *Figure 6: Add Environment variables.*

8. **Test Lambda Configuration**  
   - In **Test**, create a test event with content `{}` (simulate EventBridge).  
   - Click **Test**.  
   - Expected results:  
     - JSON file (e.g., `students-backup-20250708T1236.json`) appears in S3 `student-backup-20250706`.  
     - Email sent to `admin@studentapp.com` with subject `Backup Completed: students-backup-20250708T1236.json` and body `Backup saved to s3://student-backup-20250706/students-backup-20250708T1236.json`.  
   - **Troubleshooting**:  
     - **AccessDenied**: Check `s3:PutObject`, `dynamodb:Scan`, `ses:SendEmail` permissions in `DynamoDBBackupRole`.  
     - **No items in DynamoDB**: Call **POST /students** (section 4.5) to add data to `studentData`.  
     - **SES error**: Verify `no-reply@studentapp.com`, `admin@studentapp.com` in SES (section 3).  
     - **Environment variable not found**: Check `S3_BUCKET_NAME`, `SENDER_EMAIL`, `RECIPIENT_EMAIL` in **Environment variables**.  
     ![Lambda test result.](/images/8-setting-up-system-backup/8.1-modifying-backup-lambda-configuration/modifying-backup-lambda-configuration-08.png)
     *Figure 7: Lambda test result.*

---

## Important Notes

| **Factor** | **Details** |
|------------|-------------|
| **Security** | - Avoid embedding `StudentApiKey` in `scripts.js`. Use CloudFront Functions to add the `x-api-key` header: <br> ```javascript <br> function handler(event) { <br> var request = event.request; <br> request.headers['x-api-key'] = { value: 'xxxxxxxxxxxxxxxxxxxx' }; <br> return request; <br> } <br> ``` <br> - Verify SES emails (`no-reply@studentapp.com`, `admin@studentapp.com`) before sending. |
| **Optimization** | - Enable CloudWatch Logs for Lambda: In **Configuration > Monitoring and operations tools**, select **Enable CloudWatch Logs**. <br> - Use AWS CLI to check configuration: <br> ```bash <br> aws lambda get-function-configuration --function-name BackupDynamoDBAndSendEmail <br> ``` |
| **Integration** | - CORS: Ensure `Access-Control-Allow-Origin: https://d12345678.cloudfront.net` in API Gateway (section 4.7). <br> - Verify **POST /students**, **GET /students**, **POST /backup** endpoints work with `StudentApiKey`. |
| **Integration Testing** | - Access CloudFront URL (`https://d12345678.cloudfront.net`) and check: <br> - **POST /students**: Save record, send SES email. <br> - **GET /students**: Display table. <br> - **POST /backup**: Create file in `student-backup-20250706`, send email. <br> - Use **Developer Tools > Network** to inspect API requests. |
| **Error Handling** | - **AccessDenied**: Check permissions in `DynamoDBBackupRole` and bucket policy of `student-backup-20250706`. <br> - **SES error**: Verify SES emails. <br> - **No data**: Add data to `studentData` via **POST /students**. <br> - **Environment variable error**: Check environment variables in **Configuration**. |

> **Best practice tip**: Test Lambda after each update using the `{}` event. Check CloudWatch Logs for debugging. Prepare for section 8.2 by ensuring the function works correctly with the **POST /backup** endpoint.

---

## Conclusion

The Lambda function `BackupDynamoDBAndSendEmail` has been configured with Memory (128 MB), Ephemeral Storage (512 MB), role `DynamoDBBackupRole`, and environment variables (`S3_BUCKET_NAME`, `SENDER_EMAIL`, `RECIPIENT_EMAIL`). The function is ready to back up data from DynamoDB `studentData` to S3 `student-backup-20250706` and send emails via SES, integrated with the `student` API and web interface.

> **Next step**: Proceed to [Create EventBridge Rule for Automated Backup](/8-automatic-backup/8.2-creating-eventbridge-rule/) to enable scheduled backups!