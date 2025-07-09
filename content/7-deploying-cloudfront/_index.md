---
title: "Deploying CloudFront to Accelerate the Website"
date: 2023-10-25
weight: 7
chapter: false
pre: "<b>7. </b>"
---

> **Objective**: Deploy Amazon CloudFront, a Content Delivery Network (CDN) service, to accelerate and secure the static web interface hosted on the S3 Bucket `student-management-website-2025` (see section 6). CloudFront will:  
> - Distribute content from S3 over HTTPS, improving performance with global edge locations.  
> - Serve the `index.html` file (see section 6.2) as the default page via the **Default Root Object**.  
> - Refresh cache content when the interface is updated.  
> CloudFront integrates with the `student` API (stage `prod`, see section 4.8) to support the endpoints **GET /students**, **POST /students**, and **POST /backup**, using the `StudentApiKey` (see section 4.2) with CORS configured (see section 4.7) for calls from the CloudFront domain.

---

## Overview of CloudFront in the Application

- **Role of CloudFront**:  
  - Provides HTTPS for the web interface (S3 only supports HTTP via **Static Website Hosting**, see section 6.3).  
  - Accelerates loading speed by caching content at edge locations close to users.  
  - Integrates with the S3 Bucket `student-management-website-2025` (sections 6.1–6.4) to serve files like `index.html`, `styles.css`, `scripts.js`.  
  - Enhances API Key security using CloudFront Functions (recommended) to add the `x-api-key` header without embedding it in `scripts.js`.  
- **System Integration**:  
  - The web interface (distributed via CloudFront) calls the `student` API (see section 4.8) using the **Invoke URL** (e.g., https://abc123.execute-api.us-east-1.amazonaws.com/prod) and `StudentApiKey`.  
  - Functions:  
    - **POST /students**: Save records to DynamoDB `studentData` and send emails via SES.  
    - **GET /students**: Display data in a table.  
    - **POST /backup**: Create a backup file in the S3 Bucket `student-backup-20250706` (see section 6.5) and send notification emails via SES.  
  - CORS is configured (see section 4.7) to support requests from the CloudFront domain (e.g., https://d12345678.cloudfront.net).  

---

## Prerequisites

{{% notice info %}}
You need to complete section 6.1 (create the `student-management-website-2025` bucket), section 6.2 (upload `index.html`, `styles.css`, `scripts.js`), section 6.3 (enable **Static Website Hosting**), section 6.4 (configure **Bucket Policy**), section 6.5 (configure the `student-backup-20250706` bucket), section 5 (build the web interface), section 4.1 (create the `student` API), section 4.2 (create the `StudentApiKey`), section 4.3 (create the `StudentUsagePlan`), section 4.4 (create the **GET /students** method), section 4.5 (create the **POST /students** method), section 4.6 (create the `/backup` resource and **POST /backup** method), section 4.7 (enable CORS), section 4.8 (deploy the API to the `prod` stage), section 4.9 (attach `StudentApiKey` to `StudentUsagePlan`), section 3 (create Lambda functions, DynamoDB table `studentData`, `student-backup-20250706` bucket, SES). Ensure your AWS account has `cloudfront:CreateDistribution`, `cloudfront:CreateInvalidation` permissions, and the AWS region is `us-east-1` for related services.
{{% /notice %}}

---

## Configuration Steps

Below are the specific steps to deploy CloudFront:

| **Step** | **Content** | **Description** |
|----------|-------------|-----------------|
| 7.1 | [Create CloudFront Distribution](/7-deploying-cloudfront/7.1-creating-a-cloudfront-distribution/) | Create a CloudFront distribution to deliver content from the `student-management-website-2025` bucket over HTTPS. |
| 7.2 | [Configure Default Root Object](/7-deploying-cloudfront/7.2-configuring-default-root-object/) | Set `index.html` as the **Default Root Object** to serve as the main page when accessing the CloudFront domain. |
| 7.3 | [Create Invalidation to Refresh Cache](/7-deploying-cloudfront/7.3-creating-cloudfront-invalidation/) | Create an invalidation to refresh CloudFront cache, ensuring the latest content from S3 is served. |

> **Note**: Follow the steps in order to ensure CloudFront is configured correctly. Each step is detailed in the corresponding documentation.

---

## Conclusion

By completing these configuration steps, you will have:  
- A CloudFront distribution delivering content from the `student-management-website-2025` bucket over HTTPS, improving speed and security.  
- A web interface integrated with the `student` API (stage `prod`), supporting **GET /students**, **POST /students**, and **POST /backup** functions.  
- A system ready for testing and production deployment.

> **Ready to continue?**  
> Proceed to [Create CloudFront Distribution](/7-deploying-cloudfront/7.1-creating-a-cloudfront-distribution/) to start deploying