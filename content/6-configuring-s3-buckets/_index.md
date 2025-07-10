---
title: "Configuring S3 Bucket for Storing and Serving the Website"
date: 2025-07-09
weight: 6
chapter: false
pre: "<b>6. </b>"
---

> **Objective**: Configure two Amazon S3 Buckets for:  
> - **Storing and serving the web interface**: Create the `student-web-20250706` bucket to store static files (`index.html`, `styles.css`, `scripts.js` from section 5), enable Static Website Hosting, and configure public access permissions to serve the interface via CloudFront (section 7).  
> - **Data backup**: Configure the `student-backup-20250706` bucket (created in section 2.4) to store backup files from the **POST /backup** endpoint (section 4.6), ensuring the `BackupDynamoDBAndSendEmail` Lambda function has write permissions to the bucket.  
> This configuration integrates with the `student` API (stage `prod`, section 4.8) and ensures the web interface (using Tailwind CSS) works smoothly with the **GET /students**, **POST /students**, and **POST /backup** endpoints.

---

## Initial Requirements

{{% notice info %}}
You need to complete section 2.4 (create the `student-backup-20250706` bucket), section 3.3 (create the `BackupDynamoDBAndSendEmail` Lambda function with the `DynamoDBBackupRole` role), section 4.1 (create the `student` API), section 4.2 (create the `StudentApiKey`), section 4.3 (create the `StudentUsagePlan`), section 4.4 (create the **GET /students** method), section 4.5 (create the **POST /students** method), section 4.6 (create the `/backup` resource and **POST /backup** method), section 4.7 (enable CORS), section 4.8 (deploy the API to the `prod` stage), section 4.9 (link the `StudentApiKey` to `StudentUsagePlan` and associate with the `student` API in the `prod` stage), and section 5 (build the web interface with `index.html`, `styles.css`, `scripts.js`). Ensure that your AWS account has permissions to access S3, Lambda, API Gateway, and the AWS region is `us-east-1`.
{{% /notice %}}

---

## Configuration Steps

Below are the specific steps to configure the S3 Bucket:

| **Step** | **Content** | **Description** |
|----------|-------------|-----------------|
| 6.1 | [Create a new S3 Bucket](/6-configuring-s3-buckets/6.1-creating-a-new-s3-bucket/) | Create the `student-web-20250706` bucket to store static files (`index.html`, `styles.css`, `scripts.js`). |
| 6.2 | [Upload the web interface assets to S3 (HTML/CSS/JS)](/6-configuring-s3-buckets/6.2-uploading-static-assets-to-s3/) | Upload the static files from section 5 to the `student-web-20250706` bucket. |
| 6.3 | [Enable Static Website Hosting](/6-configuring-s3-buckets/6.3-enabling-static-website-hosting/) | Enable Static Website Hosting in the `student-web-20250706` bucket to serve the web interface. |
| 6.4 | [Configure Bucket Policy for public access](/6-configuring-s3-buckets/6.4-setting-bucket-policy-for-public-access/) | Update the Bucket Policy for `student-web-20250706` to allow CloudFront to access the content (`s3:GetObject`). |
| 6.5 | [Update Bucket Policy to support data backup (Backup)](/6-configuring-s3-buckets/6.5-updating-bucket-policy-to-support-backup/) | Update the Bucket Policy for `student-backup-20250706` to allow the `BackupDynamoDBAndSendEmail` Lambda function to write files (`s3:PutObject`). |

> **Note**: Follow the steps in order to ensure the S3 Bucket configuration is correct. Each step will be explained in detail in the corresponding documentation.

---

## Conclusion

By completing these configuration steps, you will have:  
- The `student-web-20250706` bucket storing and serving the static web interface, ready to integrate with CloudFront.  
- The `student-backup-20250706` bucket supporting the storage of backup files from the **POST /backup** endpoint, integrated with the `BackupDynamoDBAndSendEmail` Lambda function.  
- A fully integrated system with the `student` API (stage `prod`) and a web interface using Tailwind CSS.

> **Ready to continue?**  
> Go to [Create a new S3 Bucket](/6-configuring-s3-buckets/6.1-creating-a-new-s3-bucket/) to start configuring the `student-web-20250706` bucket!
