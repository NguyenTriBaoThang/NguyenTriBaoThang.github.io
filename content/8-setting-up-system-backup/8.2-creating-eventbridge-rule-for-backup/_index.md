---
title: "Create EventBridge Rule for Automated Backup"
date: 2023-10-25
weight: 2
chapter: false
pre: "<b>8.2. </b>"
---

> **Objective**: Create an Amazon EventBridge Rule `DailyDynamoDBBackup` to trigger the Lambda function `BackupDynamoDBAndSendEmail` (created in section 3.3, configured in section 8.1) on a scheduled basis, automatically backing up data from the DynamoDB table `studentData` to the S3 Bucket `student-backup-20250706` (section 6.5) and sending notification emails via Amazon SES. The schedule runs daily at 07:00 AM +07 (00:00 UTC) with a flexible time window of 5 minutes, ensuring integration with the serverless system and the web interface via CloudFront.

---

## Overview of the EventBridge Rule

- **Role of the EventBridge Rule**:  
  - Amazon EventBridge schedules and triggers the Lambda function `BackupDynamoDBAndSendEmail` periodically (daily at 07:00 AM +07, i.e., 00:00 UTC).  
  - Ensures automatic backup, saves a JSON file to S3 `student-backup-20250706`, and sends notification emails via SES, reducing manual intervention.  
  - Uses Cron expression `0 0 * * ? *` and a 5-minute Flexible Time Window to optimize performance.  
- **System Integration**:  
  - The web interface (CloudFront `StudentWebsiteDistribution`, sections 7.1–7.3) from S3 `student-management-website-2025` (sections 6.1–6.4) calls the `student` API (stage `prod`, section 4.8) with **Invoke URL** (e.g., `https://abc123.execute-api.us-east-1.amazonaws.com/prod`) and `StudentApiKey` (section 4.2).  
  - Functions:  
    - **POST /students**: Save records to DynamoDB `studentData` and send email via SES.  
    - **GET /students**: Display data in a table.  
    - **POST /backup**: Create a JSON file in `student-backup-20250706` and send notification email.  
  - CORS configured (section 4.7) to support requests from the CloudFront domain (e.g., `https://d12345678.cloudfront.net`).  
  - IAM role `DynamoDBBackupRoleStudent` (section 6.5) grants Lambda access to DynamoDB, S3, SES.  
  - EventBridge uses the role `Amazon_EventBridge_Scheduler_LAMBDA_7e5e967abf` to trigger Lambda.

---

## Prerequisites

{{% notice info %}}
You need to complete:  
- Section 2.4: Create S3 Bucket `student-backup-20250706`.  
- Section 3.3: Create Lambda function `BackupDynamoDBAndSendEmail` with role `DynamoDBBackupRoleStudent`.  
- Sections 4.1–4.9: Create the `student` API, `StudentApiKey`, `StudentUsagePlan`, **GET /students**, **POST /students**, **POST /backup** methods, enable CORS, deploy the `prod` stage.  
- Section 5: Build the web interface (`index.html`, `styles.css`, `scripts.js`).  
- Sections 6.1–6.5: Create and configure S3 Buckets `student-management-website-2025` and `student-backup-20250706`.  
- Sections 7.1–7.3: Create CloudFront `StudentWebsiteDistribution`.  
- Section 8.1: Configure Lambda `BackupDynamoDBAndSendEmail` with 128 MB Memory, 512 MB Ephemeral Storage, role `DynamoDBBackupRoleStudent`, and environment variables `S3_BUCKET_NAME`, `SENDER_EMAIL`, `RECIPIENT_EMAIL`.  
Ensure your AWS account has permissions for `events:PutRule`, `events:PutTargets`, `iam:CreateRole`, `iam:PassRole`, and the AWS region is `us-east-1`.
{{% /notice %}}

---

## Detailed Steps

1. **Access AWS Management Console and Amazon EventBridge**  
   - Log in to **[AWS Management Console](https://console.aws.amazon.com)**.  
   - Search for **EventBridge**, select **Amazon EventBridge**.  
   - Verify AWS region: `us-east-1` to synchronize with DynamoDB `studentData`, S3 (`student-management-website-2025`, `student-backup-20250706`), Lambda, API Gateway, SES, CloudFront.  
     ![AWS Console interface with EventBridge search bar.](/images/8-setting-up-system-backup/8.2-creating-eventbridge-rule-for-backup/creating-eventbridge-rule-for-backup-01.png)  
     *Figure 1: AWS Console interface with EventBridge search bar.*

2. **Select Rules**  
   - In **EventBridge**, select **Rules** from the left menu.  
   - Click **Create rule**.  
     ![Create rule button in EventBridge interface.](/images/8-setting-up-system-backup/8.2-creating-eventbridge-rule-for-backup/creating-eventbridge-rule-for-backup-02.png)  
     *Figure 2: Create rule button in EventBridge interface.*

3. **Configure the Rule**  
   - In **Create rule**:  
     - **Name**: `DailyDynamoDBBackup` (reflects daily backup purpose).  
     - **Description**: _Backup DynamoDB and send email daily at 7:00 AM +07._  
     - **Event bus**: Select **default**.  
     - **Rule type**: Select **Schedule**.  
   - Click **Continue in EventBridge Scheduler**.  
     ![Configure rule name and description.](/images/8-setting-up-system-backup/8.2-creating-eventbridge-rule-for-backup/creating-eventbridge-rule-for-backup-03.png)  
     *Figure 3: Configure rule name and description.*

4. **Set the Schedule**  
   - In **Schedule pattern**:  
     - **Occurrence**: Select **Recurring schedule**.  
     - **Schedule type**: Select **Cron-based schedule**.  
     - **Cron expression**: Enter `0 0 * * ? *` (runs at 00:00 UTC, i.e., 07:00 AM +07, every day).  
       - **Explanation**: `0 0 * * ? *` = minute 0, hour 0, every day/month, any day of week, every year.  
       - **Option**: For weekly on Sunday at 07:00 AM +07, use `0 0 * * SUN`.  
   - Check your system timezone to avoid confusion.  
   - Click **Next**.  
     ![Configure Cron schedule.](/images/8-setting-up-system-backup/8.2-creating-eventbridge-rule-for-backup/creating-eventbridge-rule-for-backup-04.png)  
     *Figure 4: Configure Cron schedule.*

5. **Configure Flexible Time Window**  
   - In **Flexible time window**:  
     - Select **Enable flexible time window**.  
     - **Maximum time window**: 5 minutes (AWS optimizes execution time within 00:00–00:05 UTC).  
       - **Reason**: Suitable for small backups like `studentData`, does not affect timeliness.  
   - Click **Next**.  
     ![Configure Flexible Time Window.](/images/8-setting-up-system-backup/8.2-creating-eventbridge-rule-for-backup/creating-eventbridge-rule-for-backup-05.png)  
     *Figure 5: Configure Flexible Time Window.*

6. **Select Target API**  
   - In **Target(s)**:  
     - **Target type**: Select **AWS service**.  
     - **Select a target**: Select **Lambda function**.  
       - **Reason**: `BackupDynamoDBAndSendEmail` is the backup execution target.  
     - Click **Next**.  
     ![Select Target API.](/images/8-setting-up-system-backup/8.2-creating-eventbridge-rule-for-backup/creating-eventbridge-rule-for-backup-06.png)  
     *Figure 6: Select Target API.*

7. **Select Lambda Function**  
   - In **Function**, select `BackupDynamoDBAndSendEmail`.  
   - **Troubleshooting**: If the function does not appear, check that it exists in `us-east-1` and you have `lambda:ListFunctions` permission.  
     ![Select Lambda function.](/images/8-setting-up-system-backup/8.2-creating-eventbridge-rule-for-backup/creating-eventbridge-rule-for-backup-07.png)  
     *Figure 7: Select Lambda function.*

8. **Configure Execution Role**  
   - In **Permissions**:  
     - Select **Create new role for this schedule**.  
     - **Role name**: `Amazon_EventBridge_Scheduler_LAMBDA_7e5e967abf`.  
       - **Reason**: This role allows EventBridge to trigger Lambda.  
     - Verify permissions:  
       ```json
       {
           "Version": "2012-10-17",
           "Statement": [
               {
                   "Effect": "Allow",
                   "Action": "lambda:InvokeFunction",
                   "Resource": "arn:aws:lambda:us-east-1:<AWS_ACCOUNT_ID>:function:BackupDynamoDBAndSendEmail",
                   "Principal": {"Service": "scheduler.amazonaws.com"}
               }
           ]
       }
       ```
       Replace `<AWS_ACCOUNT_ID>` with your AWS account ID.  
   - Click **Next**.  
     ![Configure Execution Role.](/images/8-setting-up-system-backup/8.2-creating-eventbridge-rule-for-backup/creating-eventbridge-rule-for-backup-09.png)  
     *Figure 8: Configure Execution Role.*

9. **Review and Create Schedule**  
   - Review configuration:  
     - **Name**: `DailyDynamoDBBackup`.  
     - **Description**: _Backup DynamoDB and send email daily at 7:00 AM +07._  
     - **Schedule**: `cron(0 0 * * ? *)`.  
     - **Flexible time window**: 5 minutes.  
     - **Target**: `BackupDynamoDBAndSendEmail`.  
   - Click **Create Schedule**.  
   - Result: Notification _"Your schedule DailyDynamoDBBackup is being created"_.  
     ![Review and create Schedule.](/images/8-setting-up-system-backup/8.2-creating-eventbridge-rule-for-backup/creating-eventbridge-rule-for-backup-10.png)  
     *Figure 9: Review and create Schedule.*

10. **Check the Rule**  
    - In **EventBridge > Rules**, verify `DailyDynamoDBBackup` with:  
      - **Status**: Enabled.  
      - **Schedule**: `cron(0 0 * * ? *)`.  
      - **Target**: `BackupDynamoDBAndSendEmail`.  
    - Test operation:  
      - Temporarily set the schedule to every 5 minutes: In **EventBridge > Rules**, select `DailyDynamoDBBackup` > **Edit** > **Schedule pattern**, enter `*/5 * * * ? *`, click **Update rule**.  
      - After 5 minutes (or at 00:00 UTC the next day):  
        - **S3**: Check `student-backup-20250706` for a JSON file (e.g., `students-backup-20250708T0700.json`).  
        - **SES**: Verify email at `admin@studentapp.com` with subject `Backup Completed: students-backup-20250708T0700.json` and body `Backup saved to s3://student-backup-20250706/students-backup-20250708T0700.json`.  
        - **CloudWatch Logs**: In **CloudWatch > Log groups > /aws/lambda/BackupDynamoDBAndSendEmail**, check logs:  
          ```log
          fields @timestamp, @message
          | filter @message like /Backup completed/
          | sort @timestamp desc
          ```
    - **Troubleshooting**:  
      - **Rule not triggered**:  
        - Check rule status is **Enabled**.  
        - Verify the role `Amazon_EventBridge_Scheduler_LAMBDA_7e5e967abf` has `lambda:InvokeFunction` permission.  
      - **Lambda error**:  
        - Check logs in **CloudWatch > Log groups > /aws/lambda/BackupDynamoDBAndSendEmail**.  
        - Ensure `DynamoDBBackupRoleStudent` has `dynamodb:Scan`, `s3:PutObject`, `ses:SendEmail` permissions (section 8.1).  
      - **File not appearing in S3**:  
        - Verify the `student-backup-20250706` bucket and **Bucket Policy** (section 6.5):  
          ```json
          {
              "Version": "2012-10-17",
              "Statement": [
                  {
                      "Sid": "AllowLambdaPutObject",
                      "Effect": "Allow",
                      "Principal": {"AWS": "arn:aws:iam::<AWS_ACCOUNT_ID>:role/DynamoDBBackupRoleStudent"},
                      "Action": "s3:PutObject",
                      "Resource": "arn:aws:s3:::student-backup-20250706/*"
                  }
              ]
          }
          ```
          Replace `<AWS_ACCOUNT_ID>` with your AWS account ID.  
      - **Email not sent**:  
        - Verify `no-reply@studentapp.com`, `admin@studentapp.com` in SES (section 3).  
        - Check `ses:SendEmail` permission in `DynamoDBBackupRoleStudent`.  
    - After testing, restore the schedule to `0 0 * * ? *`.  
      ![Status notification after rule creation.](/images/8-setting-up-system-backup/8.2-creating-eventbridge-rule-for-backup/creating-eventbridge-rule-for-backup-11.png)  
      *Figure 10: Status notification after rule creation.*

---

## Important Notes

| **Factor** | **Details** |
|------------|-------------|
| **Security** | - Ensure the role `Amazon_EventBridge_Scheduler_LAMBDA_7e5e967abf` only grants `lambda:InvokeFunction` permission for `BackupDynamoDBAndSendEmail`. <br> - Do not embed `StudentApiKey` in `scripts.js`. Use CloudFront Functions: <br> ```javascript <br> function handler(event) { <br> var request = event.request; <br> request.headers['x-api-key'] = { value: 'xxxxxxxxxxxxxxxxxxxx' }; <br> return request; <br> } <br> ``` |
| **Optimization** | - Enable CloudWatch Logs for Lambda (section 8.1). <br> - Check the rule using AWS CLI: <br> ```bash <br> aws events describe-rule --name DailyDynamoDBBackup <br> ``` |
| **Integration** | - Verify CORS in API Gateway (section 4.7): `Access-Control-Allow-Origin: https://d12345678.cloudfront.net`. <br> - Test the **POST /backup** endpoint via CloudFront URL to ensure integration with the web interface. |
| **Integration Testing** | - Access the CloudFront URL (`https://d12345678.cloudfront.net`): <br> - **POST /students**: Save record, send SES email. <br> - **GET /students**: Display table. <br> - **POST /backup**: Create file in `student-backup-20250706`, send email. <br> - Use **Developer Tools > Network** to inspect API requests. |
| **Error Handling** | - **Rule not running**: Check **Enabled** status, `events:PutRule`, `events:PutTargets` permissions. <br> - **Lambda error**: Check CloudWatch logs, `DynamoDBBackupRoleStudent` permissions. <br> - **File not appearing**: Verify `student-backup-20250706` bucket policy. <br> - **Email not sent**: Verify SES email and `ses:SendEmail` permission. |

> **Best practice tip**: Test the rule immediately with schedule `*/5 * * * ? *`, then revert to `0 0 * * ? *`. Check CloudWatch Logs and S3 to verify backup. Configure S3 Lifecycle Rule for `student-backup-20250706` to manage old files.

---

## Conclusion

The `DailyDynamoDBBackup` rule is created to trigger the Lambda `BackupDynamoDBAndSendEmail` daily at 07:00 AM +07, saving data from DynamoDB `studentData` to S3 `student-backup-20250706` and sending email via SES. The system is integrated with the `student` API and the web interface via CloudFront.

> **Next step**: Monitor backups in S3 and SES emails,