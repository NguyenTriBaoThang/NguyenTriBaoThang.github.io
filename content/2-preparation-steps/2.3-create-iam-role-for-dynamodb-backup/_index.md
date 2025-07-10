---
title: "Create IAM Role for DynamoDB Backup"
date: 2025-07-09
weight: 3
chapter: false
pre: "<b>2.3. </b>"
---

> **Objective**: Create the IAM role **DynamoDBBackupRole** for the Lambda function `BackupDynamoDBAndSendEmail`, granting permissions to **read and write data** to the DynamoDB table `studentData`, **store backup files** in S3, **send emails** via SES, **log data** to CloudWatch, and support potential interactions with CloudFront.

The function **BackupDynamoDBAndSendEmail** performs:  
- **Reads student data** (**Student ID**, **Full Name**, **Class**, **Date of Birth**, **Email**) from the DynamoDB table `studentData` via the **Scan** operation.  
- **Stores a JSON file** in an S3 bucket (e.g., `student-backup-20250706`).  
- **Creates a pre-signed URL** for the backup file and **sends a notification email** via SES (e.g., to `nguyentribaothang@gmail.com`).  
- **Logs data** to CloudWatch for monitoring.

This role needs:  
- Permissions to **read and write data** to DynamoDB (`AmazonDynamoDBFullAccess`).  
- Permissions to **store and create URLs** on S3 (`AmazonS3FullAccess`).  
- Permissions to **send emails** via SES (`AmazonSESFullAccess`).  
- Permissions to **log data** to CloudWatch (`AWSLambdaBasicExecutionRole`).  
- Permissions for **CloudFront** (`CloudFrontFullAccess`) for potential future features.

> **Note**: `CloudFrontFullAccess` is not currently used but is retained for future functionalities (e.g., managing CloudFront distributions).

---

## Detailed Steps

Below are the detailed steps to create the IAM role **DynamoDBBackupRole**:

### 1. Access the AWS Management Console
- Open your browser and log in to the **[AWS Management Console](https://console.aws.amazon.com)** with your AWS account.
- In the search bar, type **IAM** and select **Identity and Access Management (IAM)**.
- Ensure you are in the correct AWS region (e.g., `us-east-1`), check in the top right corner.

  ![IAM - Access Service](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-01.png)
  *Figure 1: AWS Console interface with the IAM search bar.*

### 2. Navigate to the Roles Section
- In the IAM interface, find the **left-hand navigation menu**.
- Select **Roles** to view the list of IAM roles. If no roles exist, the list will be empty.

  ![IAM - Roles List](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-02.png)
  *Figure 2: Navigation menu with the Roles option.*

### 3. Start the Role Creation Process
- In the **Roles** interface, click the **Create Role** button in the top-right corner.

  ![IAM - Create Role Button](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-03.png)
  *Figure 3: Create Role button in the Roles interface.*

### 4. Choose Trusted Entity Type
- In the **Select trusted entity** section, choose **AWS Service** to specify that the role is for an AWS service.
- In the **Use case** section, select **Lambda** from the list of services.
- Click **Next** to move to the permission configuration step.

  ![IAM - Choose Lambda Service](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-04.png)
  *Figure 4: Choosing AWS Service and Lambda in Use case.*

### 5. Grant Permissions to the Role
- In the **Permissions** section, add the following five policies:
  - **AmazonDynamoDBFullAccess**:
    - Type `AmazonDynamoDBFullAccess` in the search bar.
    - Select the **AmazonDynamoDBFullAccess** policy.  
      > **Description**: Grants read and write access to DynamoDB, supporting operations like **Scan** and other operations if needed.

    ![IAM - Add AmazonDynamoDBFullAccess](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-05.png)
    *Figure 5: Selecting the AmazonDynamoDBFullAccess policy.*

  - **AmazonS3FullAccess**:
    - Type `AmazonS3FullAccess` in the search bar.
    - Select the **AmazonS3FullAccess** policy.  
      > **Description**: Grants permissions to store backup files in S3 (`PutObject`) and create pre-signed URLs (`GeneratePresignedUrl`).

    ![IAM - Add AmazonS3FullAccess](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-06.png)
    *Figure 6: Selecting the AmazonS3FullAccess policy.*

  - **AmazonSESFullAccess**:
    - Type `AmazonSESFullAccess` in the search bar.
    - Select the **AmazonSESFullAccess** policy.  
      > **Description**: Grants permission to send emails via SES to notify users with a backup download link (e.g., to `nguyentribaothang@gmail.com`).

    ![IAM - Add AmazonSESFullAccess](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-07.png)
    *Figure 7: Selecting the AmazonSESFullAccess policy.*

  - **AWSLambdaBasicExecutionRole**:
    - Type `AWSLambdaBasicExecutionRole` in the search bar.
    - Select the **AWSLambdaBasicExecutionRole** policy.  
      > **Description**: Allows the Lambda function to log to CloudWatch for monitoring and debugging.

    ![IAM - Add AWSLambdaBasicExecutionRole](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-08.png)
    *Figure 8: Selecting the AWSLambdaBasicExecutionRole policy.*

  - **CloudFrontFullAccess**:
    - Type `CloudFrontFullAccess` in the search bar.
    - Select the **CloudFrontFullAccess** policy.  
      > **Description**: Grants permission to manage CloudFront distributions for potential future features.

    ![IAM - Add CloudFrontFullAccess](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-09.png)
    *Figure 9: Selecting the CloudFrontFullAccess policy.*

- Verify the list of **Permissions policies** to ensure it includes:  
  - `AmazonDynamoDBFullAccess`  
  - `AmazonS3FullAccess`  
  - `AmazonSESFullAccess`  
  - `AWSLambdaBasicExecutionRole`  
  - `CloudFrontFullAccess`  
- Click **Next**.

### 6. Name and Review the Role
- In the **Role details** section:
  - **Role Name**: Enter `DynamoDBBackupRole`.  
    > **Note**: The name must match exactly with the Lambda function configuration for `BackupDynamoDBAndSendEmail`.
  - **Description** (optional): Enter a description, e.g., _"IAM role for Lambda function BackupDynamoDBAndSendEmail, granting read and write access to DynamoDB, store backups to S3, send emails via SES, log to CloudWatch, and support CloudFront."_

  ![IAM - Enter Role Name](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-10.png)
  *Figure 10: Enter role name and description.*

- Double-check:
  - **Trusted entity**: AWS Service (Lambda).
  - **Permissions**: `AmazonDynamoDBFullAccess`, `AmazonS3FullAccess`, `AmazonSESFullAccess`, `AWSLambdaBasicExecutionRole`, `CloudFrontFullAccess`.
- Click **Create Role**.

  ![IAM - Confirm Create Role](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-11.png)
  *Figure 11: Create Role button to finalize the creation.*

###
