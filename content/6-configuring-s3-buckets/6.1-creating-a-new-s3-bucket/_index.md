---
title: "Create a New S3 Bucket"
date: 2023-10-25
weight: 1
chapter: false
pre: "<b>6.1 </b>"
---

> **Objective**: Create a new Amazon S3 Bucket named `student-management-website-2025` to store static files (`index.html`, `styles.css`, `scripts.js` from section 5) for the Student Data Management application's web interface. This bucket will be configured to support **Static Website Hosting** (section 6.3) and serve content via CloudFront (section 7), integrated with the `student` API (stage `prod`, section 4.8) to call the **GET /students**, **POST /students**, and **POST /backup** endpoints with API Key security (`StudentApiKey`, section 4.2) and CORS (section 4.7).

---

## Overview of the S3 Bucket in the Application

- **Role of the `student-management-website-2025` bucket**:  
  - Store static files (`index.html`, `styles.css`, `scripts.js`) for the web interface using Tailwind CSS.  
  - Enable **Static Website Hosting** to provide an endpoint to access the interface (to be distributed via CloudFront to support HTTPS and high performance).  
  - Uncheck **Block all public access** to allow the configuration of public access permissions (`s3:GetObject`) in the **Bucket Policy** (section 6.4), which is required for CloudFront to access the content.  
  - Enable **Bucket Versioning** to store versions of the files, supporting recovery in case of errors when updating the interface.  
- **Integration with the system**:  
  - The web interface calls the `student` API (section 4.8) using the **Invoke URL** (e.g., `https://abc123.execute-api.us-east-1.amazonaws.com/prod`) and `StudentApiKey` in the `x-api-key` header.  
  - CORS is configured (section 4.7) to support requests from the CloudFront domain (e.g., `https://d12345678.cloudfront.net`).  
  - This bucket differs from the `student-backup-20250706` bucket (section 2.4, 6.5), which is used to store backup files from the **POST /backup** endpoint.

---

## Initial Requirements

{{% notice info %}}
You need to complete section 2.4 (create the `student-backup-20250706` bucket), section 3 (create the Lambda functions `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, DynamoDB table `studentData`, SES email verification), section 4.1 (create the `student` API), section 4.2 (create the `StudentApiKey`), section 4.3 (create `StudentUsagePlan`), section 4.4 (create the **GET /students** method), section 4.5 (create the **POST /students** method), section 4.6 (create the `/backup` resource and **POST /backup** method), section 4.7 (enable CORS), section 4.8 (deploy the API to the `prod` stage), section 4.9 (link the `StudentApiKey` to `StudentUsagePlan` and associate with the `student` API in the `prod` stage), and section 5 (build the web interface with `index.html`, `styles.css`, `scripts.js`). Ensure your AWS account has permissions to access S3 (`s3:CreateBucket`, `s3:PutBucketPolicy`) and the AWS region is `us-east-1`.
{{% /notice %}}

---

## Detailed Actions

1. **Access the AWS Management Console**  
   - Open your browser and log into the **[AWS Management Console](https://console.aws.amazon.com)** using your AWS account.  
   - In the search bar at the top of the page, type **S3** and select the **Amazon S3** service to enter the bucket management interface.  
   - Check the AWS region: Ensure you are working in the **us-east-1** (US East (N. Virginia)) region to sync with the `student` API, Lambda functions (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`), DynamoDB table `studentData`, `student-backup-20250706` bucket, and SES. The region is displayed in the top right corner of the AWS Console.  
     ![AWS Console Interface with S3 Search Bar](/images/6-configuring-s3-buckets/6.1-creating-a-new-s3-bucket/creating-a-new-s3-bucket-01.png)
     *Figure 1: AWS Console Interface with the S3 search bar.*

2. **Open the Create Bucket Interface**  
   - In the main Amazon S3 interface, look at the left navigation menu or the main section.  
   - Click the **Create bucket** button (usually located at the top right) to open the create bucket configuration interface.  
   - **Note**: If the interface shows a list of existing buckets, check if the `student-management-website-2025` bucket already exists to avoid duplication.  
     ![Create Bucket Button in the S3 Interface](/images/6-configuring-s3-buckets/6.1-creating-a-new-s3-bucket/creating-a-new-s3-bucket-02.png)
     *Figure 2: Create Bucket Button in the S3 Interface.*

3. **Configure the `student-management-website-2025` Bucket**  
   - In the **Create bucket** interface, enter the following information:  
     - **Bucket name**: Enter `student-management-website-2025`.  
       - The bucket name must be globally unique (it cannot be the same as any existing bucket in AWS).  
       - If the name is already taken, try adding a random suffix (e.g., `student-management-website-20250706-abc123`).  
       - The name must follow the rules: only lowercase letters, numbers, hyphens (-), and no spaces or other special characters.  
     - **AWS Region**: Select **US East (N. Virginia) us-east-1** to sync with other services in the system.  
     - **Bucket type**: Choose **General purpose** (suitable for storing static content).  
     - **Object Ownership**:  
       - Choose **ACLs enabled** > **Bucket owner preferred** to support public access permissions via **Bucket Policy** (section 6.4).  
       - This allows managing permissions using Access Control Lists (ACLs) and Bucket Policy, which is necessary for CloudFront to access the files.  
       ![Configure Bucket Name and AWS Region](/images/6-configuring-s3-buckets/6.1-creating-a-new-s3-bucket/creating-a-new-s3-bucket-03.png)
       *Figure 3: Configure Bucket Name and AWS Region.*  
     - **Block Public Access settings for this bucket**:  
       - Uncheck **Block all public access** and all related sub-options:  
         - *Block public access to buckets and objects granted through new access control lists*  
         - *Block public access to buckets and objects granted through new public bucket or access point policies*  
         - *Block public access from access points*  
       - **Reason**: Public access (`s3:GetObject`) needs to be allowed for CloudFront to serve the web interface. After configuring the **Bucket Policy** (section 6.4), unrelated options can be enabled again for added security.  
       ![Uncheck Block Public Access](/images/6-configuring-s3-buckets/6.1-creating-a-new-s3-bucket/creating-a-new-s3-bucket-04.png)
       *Figure 4: Uncheck Block Public Access.*  
     - **Bucket Versioning**:  
       - Select **Enable** to enable **Bucket Versioning**.  
       - **Reason**: Store versions of the files (`index.html`, `styles.css`, `scripts.js`) to recover them if errors occur while updating the interface (e.g., mistakenly uploading the wrong file).  
       ![Enable Bucket Versioning](/images/6-configuring-s3-buckets/6.1-creating-a-new-s3-bucket/creating-a-new-s3-bucket-05.png)
       *Figure 5: Enable Bucket Versioning.*  
     - **Tags (Optional)**:  
       - Add tags to manage costs, e.g., `Project=StudentManagement`, `Environment=Production`.  
     - **Default encryption**:  
       - Select **Enable** > **Server-side encryption with Amazon S3-managed keys (SSE-S3)** to encrypt data at rest, enhancing security for the interface files.  
     - **Advanced settings**: Leave the defaults (no need to configure Object Lock or Multi-Region Access Points for static content).  
   - Review configuration: Check the information, especially the bucket name, region, and **Block Public Access** settings.  
   - Click **Create bucket** to finish.  
     ![Review and Click Create Bucket](/images/6-configuring-s3-buckets/6.1-creating-a-new-s3-bucket/creating-a-new-s3-bucket-06.png)
     *Figure 6: Review and Click Create Bucket.*

4. **Create the Bucket**  
   - After clicking **Create bucket**, you should see the message: _"Successfully created bucket 'student-management-website-2025'."_  
   - Expected result: In the **Buckets** list, the `student-management-website-2025` bucket should appear with a newly created status.  
   - **Error handling**:  
     - If you encounter the _"Bucket name already exists"_:  
       - Change the bucket name (e.g., `student-management-website-20250706-<random-string>`).  
       - Check if you have permissions to create a bucket (`s3:CreateBucket`) in the IAM role.  
     - If you encounter the _"AccessDenied"_:  
       - Check if the IAM role for your AWS account has `s3:CreateBucket` and `s3:PutBucketPolicy` permissions.  
     ![Bucket Creation Status Notification](/images/6-configuring-s3-buckets/6.1-creating-a-new-s3-bucket/creating-a-new-s3-bucket-07.png)  
     *Figure 7: Bucket Creation Status Notification.*

5. **Check the Bucket**  
   - In **S3 > Buckets**, select `student-management-website-2025` to verify:  
     - **Properties**: Check the region (`us-east-1`), **Bucket Versioning** (Enabled), **Default encryption** (SSE-S3).  
     - **Permissions**: Verify that **Block all public access** is unchecked to support the **Bucket Policy** (section 6.4).  
   - **Note**: This bucket will be used to upload interface files (section 6.2), enable **Static Website Hosting** (section 6.3), and configure public access permissions (section 6.4) before integrating with CloudFront.

---

## Important Notes

| **Factor** | **Details** |
|------------|-------------|
| **Bucket Name** | - The name `student-management-website-2025` is recommended for easy identification, but it must be globally unique. If it’s already taken, add a random suffix (e.g., `student-management-website-20250706-abc123`). <br> - Ensure it does not conflict with the backup bucket (`student-backup-20250706`, section 2.4). |
| **Security** | - Unchecking **Block all public access** is temporary to configure **Bucket Policy** (section 6.4). After configuring, unrelated options can be re-enabled for better security. <br> - For better security, use CloudFront **Origin Access Identity (OAI)** instead of full public access (section 6.4). <br> - Do not store `API_KEY` in static files. Use AWS Secrets Manager or CloudFront Functions to add the `x-api-key` header (section 5). |
| **AWS Region** | - Ensure the region `us-east-1` matches with the `student-management-website-2025` bucket, `student-backup-20250706`, `student` API, `prod` stage, Lambda functions (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`), DynamoDB `studentData`, SES, and CloudFront. |
| **Error Handling** | - If the bucket does not appear: Refresh the page or check the AWS region. <br> - If unable to create the bucket: Check the bucket limit in the account (default 100 buckets per region, may require AWS to increase the quota). <br> - If encountering `AccessDenied`: Verify IAM role permissions for `s3:CreateBucket` and `s3:PutBucketPolicy`. |
| **Optimization** | - Add **S3 Access Logs** to track access: In **S3 > student-management-website-2025 > Properties > Server access logging**, select **Enable** and specify a log bucket (e.g., `student-web-logs-20250706`). <br> - Use AWS CLI or SDK to automate bucket creation:
| **Integration Testing** | - Verify that the `student-management-website-2025` bucket exists in **S3 > Buckets** with the correct region (`us-east-1`) and **Bucket Versioning** (Enabled). <br> - Prepare the `index.html`, `styles.css`, `scripts.js` files (section 5) to upload (section 6.2). <br> - After completing section 6, access the interface via the CloudFront URL (e.g., `https://d12345678.cloudfront.net`) and check the following functionalities: <br> - **POST /students**: Save records to DynamoDB `studentData` and send email via SES. <br> - **GET /students**: Display the student table. <br> - **POST /backup**: Create backup files in `student-backup-20250706` and send notification emails. |

> **Best Practice Tip**: After creating the bucket, immediately check it in **S3 > Buckets** to verify the information. Use AWS CLI or SDK to automate if you need to create multiple buckets. Prepare the interface files from section 5 and verify IAM permissions before proceeding with section 6.2 (uploading files to S3).

---

## Conclusion

The `student-management-website-2025` bucket has been successfully created in the `us-east-1` region, with **Bucket Versioning** and **Default encryption** enabled, ready for uploading interface files (section 6.2), enabling **Static Website Hosting** (section 6.3), and integrating with CloudFront.

> **Next step**: Proceed to [Upload the interface assets to S3](/6-configuring-s3-buckets/6.2-uploading-static-assets-to-s3/) to continue configuring!
