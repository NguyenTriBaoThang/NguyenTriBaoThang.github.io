---
title: "Update Bucket Policy to Support Data Backup"
date: 2025-07-09
weight: 5
chapter: false
pre: "<b>6.5. </b>"
---

> **Objective**: Create the S3 Bucket `student-backup-20250706` (if not already created in section 2.4) and configure the **Bucket Policy** to allow the Lambda function `BackupDynamoDBAndSendEmail` (with the `DynamoDBBackupRole` role, section 3.3) to write backup files (JSON/CSV) to the bucket via the **POST /backup** endpoint (section 4.6). This bucket stores backup data from the DynamoDB table `studentData` and integrates with SES to send notification emails. The bucket does not require public access, only `s3:PutObject` permission for the `DynamoDBBackupRole` role, ensuring security and seamless integration with the serverless system.

---

## Overview of the Backup Bucket

- **Role of the `student-backup-20250706` bucket**:  
  - Stores backup files (JSON/CSV) created by the Lambda function `BackupDynamoDBAndSendEmail` when calling the **POST /backup** endpoint.  
  - Configured to only allow the `DynamoDBBackupRole` role to write files (`s3:PutObject`, `s3:PutObjectAcl`), with no public access.  
  - Integrated with the `student` API (stage `prod`, section 4.8) and SES to send notification emails after backup.  
- **System integration**:  
  - Lambda function `BackupDynamoDBAndSendEmail` (section 3.3):  
    - Reads data from DynamoDB `studentData` (`dynamodb:Scan`, `dynamodb:Query`).  
    - Writes backup files to `student-backup-20250706` (`s3:PutObject`).  
    - Sends notification emails via SES (`ses:SendEmail`, `ses:SendRawEmail`).  
  - **POST /backup** endpoint (section 4.6) is called from the web interface (`scripts.js`, section 6.2) via the **Invoke URL** (e.g., https://abc123.execute-api.us-east-1.amazonaws.com/prod/backup) with header `x-api-key: <StudentApiKey>` (section 4.2).  
  - CORS is configured (section 4.7) to support requests from the CloudFront domain (e.g., https://d12345678.cloudfront.net).  
- **Why public access is not allowed**:  
  - The `student-backup-20250706` bucket only needs write access from Lambda, not public access like the `student-management-website-2025` bucket (section 6.4).  
  - **Block all public access** is enabled for security, only allowing the `DynamoDBBackupRole` role to access.

---

## Prerequisites

{{% notice info %}}
You need to complete section 2.4 (create the `student-backup-20250706` bucket), section 3.3 (create the Lambda function `BackupDynamoDBAndSendEmail` with the `DynamoDBBackupRole` role), section 4.1 (create the `student` API), section 4.2 (create the `StudentApiKey`), section 4.3 (create the `StudentUsagePlan`), section 4.6 (create the `/backup` resource and **POST /backup** method), section 4.7 (enable CORS), section 4.8 (deploy the API to the `prod` stage), section 4.9 (attach `StudentApiKey` to `StudentUsagePlan`), section 5 (build the web interface with `scripts.js`), section 6.1 (create the `student-management-website-2025` bucket). Ensure your AWS account has `s3:CreateBucket`, `s3:PutBucketPolicy` permissions and the AWS region is `us-east-1`.
{{% /notice %}}

---

## Detailed Steps

1. **Access AWS Management Console**  
   - Open your browser and log in to the **[AWS Management Console](https://console.aws.amazon.com)** with your AWS account.  
   - In the search bar at the top, type **S3** and select the **Amazon S3** service to access the bucket management interface.  
   - Check AWS region: Make sure you are working in **us-east-1** (US East (N. Virginia)) to synchronize with the `student-backup-20250706` bucket, `student` API, Lambda functions (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`), DynamoDB table `studentData`, and SES. The region is shown in the top right corner of the AWS Console.  
     ![AWS Console interface with S3 search bar.](/images/6-configuring-s3-buckets/6.5-updating-bucket-policy-to-support-backup/updating-bucket-policy-to-support-backup-01.png)  
     *Figure 1: AWS Console interface with S3 search bar.*

2. **Create the `student-backup-20250706` Bucket**  
   - Check existing buckets: In **S3 > Buckets**, look for the `student-backup-20250706` bucket (assumed created in section 2.4). If it exists, skip creation and move to Step 3.  
   - In the main **Amazon S3** interface, click **Create bucket** (usually in the top right corner).  
     ![Create bucket button in S3 interface.](/images/6-configuring-s3-buckets/6.5-updating-bucket-policy-to-support-backup/updating-bucket-policy-to-support-backup-02.png)  
     *Figure 2: Create bucket button in S3 interface.*  
   - In the **Create bucket** interface, enter the following:  
     - **Bucket name**: Enter `student-backup-20250706`.  
       - The bucket name must be globally unique. If taken, try adding a random suffix (e.g., `student-backup-20250706-abc123`).  
       - Name must contain only lowercase letters, numbers, hyphens (-), no spaces or special characters.  
     - **AWS Region**: Select **US East (N. Virginia) us-east-1** to match other services.  
     - **Bucket type**: Select **General purpose** (suitable for backup file storage).  
     - **Object Ownership**: Select **ACLs disabled** (recommended for non-public buckets) to manage permissions via **Bucket Policy** and IAM.
     - **Block Public Access settings for this bucket**: Keep **Block all public access** selected (default) to ensure the bucket is not publicly accessible.  
       ![Block Public Access selected.](/images/6-configuring-s3-buckets/6.5-updating-bucket-policy-to-support-backup/updating-bucket-policy-to-support-backup-04.png)  
       *Figure 3: Block Public Access selected.*  
     - **Bucket Versioning**: Select **Disable** (as required).  
       - **Note**: It is recommended to **Enable** to store versions of backup files, supporting recovery if write errors occur. If enabled, use AWS CLI:  
         ```bash
         aws s3api put-bucket-versioning --bucket student-backup-20250706 --versioning-configuration Status=Enabled
         ```  
       ![Enable Bucket Versioning.](/images/6-configuring-s3-buckets/6.5-updating-bucket-policy-to-support-backup/updating-bucket-policy-to-support-backup-05.png)  
       *Figure 4: Enable Bucket Versioning.*  
     - **Default encryption**: Select **Enable** > **Server-side encryption with Amazon S3-managed keys (SSE-S3)** to encrypt data at rest for better security.  
     - **Tags** (Optional): Add tags for cost management, e.g., `Project=StudentManagement`, `Environment=Production`.  
   - Click **Create bucket**.  
     ![Review and click Create bucket.](/images/6-configuring-s3-buckets/6.5-updating-bucket-policy-to-support-backup/updating-bucket-policy-to-support-backup-06.png)  
     *Figure 5: Review and click Create bucket.*  
   - Expected result: AWS S3 shows the message _"Successfully created bucket 'student-backup-20250706'"_.  
     ![Bucket creation status message.](/images/6-configuring-s3-buckets/6.5-updating-bucket-policy-to-support-backup/updating-bucket-policy-to-support-backup-07.png)  
     *Figure 6: Bucket creation status message.*  
   - **Troubleshooting**:  
     - **"Bucket name already exists"**: Change the bucket name (e.g., `student-backup-20250706-<random-string>`). Check `s3:CreateBucket` permission in your IAM role.  
     - **"AccessDenied"**: Check your IAM role has `s3:CreateBucket` permission:  
       ```json
       {
           "Version": "2012-10-17",
           "Statement": [
               {
                   "Effect": "Allow",
                   "Action": "s3:CreateBucket",
                   "Resource": "*"
               }
           ]
       }
       ```

3. **Access the Bucket's Permissions Tab**  
   - In **S3 > Buckets**, select the `student-backup-20250706` bucket.  
   - Click the **Permissions** tab (usually at the top, next to Objects, Properties, etc.).  
   - Scroll down to the **Bucket policy** section to view the current status (default is empty if not configured).  
     ![Permissions tab and Bucket policy section.](/images/6-configuring-s3-buckets/6.5-updating-bucket-policy-to-support-backup/updating-bucket-policy-to-support-backup-03.png)  
     *Figure 7: Permissions tab and Bucket policy section.*

4. **Edit the Bucket Policy**
- In the **Bucket policy** section, click **Edit** to open the editor.  
   - Paste the following JSON to allow the `DynamoDBBackupRole` role to write files (`s3:PutObject`, `s3:PutObjectAcl`):  
     ```json
     {
         "Version": "2012-10-17",
         "Statement": [
             {
                 "Sid": "AllowLambdaPutObject",
                 "Effect": "Allow",
                 "Principal": {
                     "AWS": "arn:aws:iam::<AWS_ACCOUNT_ID>:role/DynamoDBBackupRole"
                 },
                 "Action": [
                     "s3:PutObject",
                     "s3:PutObjectAcl"
                 ],
                 "Resource": "arn:aws:s3:::student-backup-20250706/*"
             }
         ]
     }
     ```
   - **Explanation of the JSON**:  
     - **Version**: "2012-10-17" is the latest IAM policy format version.  
     - **Statement**: List of permission statements.  
     - **Sid**: "AllowLambdaPutObject" is an optional identifier for the policy.  
     - **Effect**: "Allow" permits the specified actions.  
     - **Principal**: "arn:aws:iam::<AWS_ACCOUNT_ID>:role/DynamoDBBackupRole" specifies the IAM role of the Lambda `BackupDynamoDBAndSendEmail`.  
     - **Action**:  
       - `s3:PutObject`: Allows writing backup files to the bucket.  
       - `s3:PutObjectAcl`: Allows setting ACL on files (if needed).  
     - **Resource**: "arn:aws:s3:::student-backup-20250706/*" specifies all files in the `student-backup-20250706` bucket.  
   - **Replace `<AWS_ACCOUNT_ID>`**:  
     - Find your AWS account ID in **IAM > Users** or **Account** (e.g., 123456789012).  
     - Replace in the ARN: `arn:aws:iam::123456789012:role/DynamoDBBackupRole`.  
   - Check the code: Ensure the ARN in **Resource** and **Principal** is correct and matches your actual bucket/role.  
     ![Configure Bucket Policy.](/images/6-configuring-s3-buckets/6.5-updating-bucket-policy-to-support-backup/updating-bucket-policy-to-support-backup-04.png)  
     *Figure 8: Configure Bucket Policy.*

5. **Save Changes**  
   - Click **Save changes** to apply the **Bucket Policy**.  
   - Expected result: AWS S3 shows the message _"Successfully edited bucket policy"_.  
     ![Click Save changes.](/images/6-configuring-s3-buckets/6.5-updating-bucket-policy-to-support-backup/updating-bucket-policy-to-support-backup-05.png)  
     *Figure 9: Click Save changes.*  
   - **Troubleshooting**:  
     - **"Policy has invalid resource"**: Check the ARN in **Resource** is correct (`arn:aws:s3:::student-backup-20250706/*`).  
     - **"Invalid principal in policy"**: Verify the ARN of `DynamoDBBackupRole` is correct and the role exists in IAM.  
     - **"AccessDenied"**: Check your IAM role has `s3:PutBucketPolicy` permission:  
       ```json
       {
           "Version": "2012-10-17",
           "Statement": [
               {
                   "Effect": "Allow",
                   "Action": "s3:PutBucketPolicy",
                   "Resource": "arn:aws:s3:::student-backup-20250706"
               }
           ]
       }
       ```

6. **Check Lambda Permissions**  
   - Verify the `DynamoDBBackupRole` role:  
     - In **IAM > Roles**, find `DynamoDBBackupRole` (created in section 3.3).  
     - Ensure the role has `s3:PutObject` and `s3:PutObjectAcl` permissions for the `student-backup-20250706` bucket:  
       ```json
       {
           "Version": "2012-10-17",
           "Statement": [
               {
                   "Effect": "Allow",
                   "Action": [
                       "s3:PutObject",
                       "s3:PutObjectAcl"
                   ],
                   "Resource": "arn:aws:s3:::student-backup-20250706/*"
               }
           ]
       }
       ```
   - Check the **POST /backup** endpoint:  
     - Call the endpoint using curl to verify the Lambda can write backup files:  
       ```bash
       curl -X POST https://abc123.execute-api.us-east-1.amazonaws.com/prod/backup \
           -H "x-api-key: xxxxxxxxxxxxxxxxxxxx" \
           -H "Content-Type: application/json"
       ```
     - Expected result:  
       - Backup file (JSON/CSV) is created in **S3 > student-backup-20250706 > Objects** (e.g., `backup-20250706.json`).  
       - Notification email is sent via SES (check your inbox, including Spam/Junk).  
     - **Troubleshooting**:  
       - **403 Forbidden error**:  
         - Check the ARN in the **Bucket Policy** (**Resource** and **Principal**) matches the bucket and role.  
         - Verify `DynamoDBBackupRole` has `s3:PutObject` permission and is attached to the `BackupDynamoDBAndSendEmail` Lambda.  
       - **Backup file not appearing**:  
         - Check the Lambda CloudWatch log (`/aws/lambda/BackupDynamoDBAndSendEmail`) for errors.  
         - Ensure the **POST /backup** endpoint returns status 200 and no CORS errors.  
       - **CORS error**:  
         - Check the `Access-Control-Allow-Origin` header in Lambda (section 3.3) and API Gateway (section 4.7).  
         - Ensure CORS supports the CloudFront domain (e.g., https://d12345678.cloudfront.net).

---

## Important Notes

| Factor | Details |
|--------|---------|
| Security | Keep **Block all public access** enabled to ensure the `student-backup-20250706` bucket is not publicly accessible. Only the `DynamoDBBackupRole` role is allowed to write files. Avoid embedding `StudentApiKey` in `scripts.js`; use AWS Secrets Manager or CloudFront Functions: <br> function handler(event) { var request = event.request; request.headers['x-api-key'] = { value: 'xxxxxxxxxxxxxxxxxxxx' }; return request; } |
| Optimization | Enable **S3 Access Logs**: In S3 > student-backup-20250706 > Properties > Server access logging, select **Enable**, specify a log bucket (e.g., student-backup-logs-20250706). Use AWS CLI to automate: <br> aws s3api put-bucket-policy --bucket student-backup-20250706 --policy file://policy.json |
| System integration | Ensure the **POST /backup** endpoint works with the **Invoke URL** and `StudentApiKey`. Update CORS in API Gateway (section 4.7) with `Access-Control-Allow-Origin: https://d12345678.cloudfront.net`. Integrate with CloudFront (section 7) to call the API from the web interface. |
| Integration testing | Call **POST /backup** from the web interface (https://d12345678.cloudfront.net) or curl. Check: <br> - Backup file appears in `student-backup-20250706`. <br> - SES email is sent. <br> Use **Developer Tools > Network** to inspect API requests. |
| Troubleshooting | **403 Forbidden**: Check ARN in **Bucket Policy**, `s3:PutObject` permission for `DynamoDBBackupRole`. **File not appearing**: Check CloudWatch logs, Lambda code. **CORS**: Check `Access-Control-Allow-Origin` header in Lambda (section 3.3) and API Gateway (section 4.7). **429**: Check Rate/Burst/Quota limits in `StudentUsagePlan` (section 4.3). |

> **Practical tip**: Check the **Bucket Policy** and IAM permissions of `DynamoDBBackupRole` before calling **POST /backup**. Use AWS CLI to automate if you need to apply the policy to multiple buckets. Prepare for section 7 (CloudFront configuration) to complete the integration.

---

## Conclusion

The `student-backup-20250706` bucket has been created and the **Bucket Policy** configured to allow the `BackupDynamoDBAndSendEmail` Lambda function to write backup files. The bucket is ready to integrate with the **POST /backup** endpoint and CloudFront (section 7).

> **Next step**: Go to [Configure CloudFront for content distribution](/7-configuring-cloudfront/) to continue setup!