---
title: "Configuring RESTful API with API Key Security"
date: 2023-10-25
weight: 4
chapter: false
pre: "<b>4. </b>"
---

> **Objective**: Create a RESTful API using AWS API Gateway to integrate with Lambda functions (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`), allowing the web interface (running on CloudFront) to access, store, and back up student data. The API will be secured with an API Key, use a Usage Plan to limit access, and enable CORS to support communication with the web interface. The API will be deployed on a specific stage (e.g., `prod`) and linked with the API Key to ensure that only valid requests are processed.

---

## Prerequisites

{{% notice info %}}
You need to complete the steps in section 3 (create Lambda functions `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, DynamoDB table `studentData`, S3 bucket `student-backup-20250706`, SES email verification). Ensure your AWS account is set up, and the AWS region is `us-east-1`.
{{% /notice %}}

---

## Configuration Steps

Below are the specific steps to configure the RESTful API:

| **Step** | **Content** | **Description** |
|----------|-------------|-----------------|
| 4.1 | [Create a new REST API on API Gateway](/4-creating-a-restful-api/4.1-creating-a-rest-api/) | Create a new REST API in AWS API Gateway to integrate with Lambda functions. |
| 4.2 | [Create API Key to secure access](/4-creating-a-restful-api/4.2-creating-an-api-key/) | Create an API Key to secure API requests from the web interface. |
| 4.3 | [Set up Usage Plan](/4-creating-a-restful-api/4.3-creating-a-usage-plan/) | Set up a Usage Plan to limit the number of API requests and manage access. |
| 4.4 | [Create GET method to fetch data](/4-creating-a-restful-api/4.4-creating-a-get-method/) | Create a GET method for the `/students` endpoint to call the `getStudentData` function and retrieve student data. |
| 4.5 | [Create POST method to store data](/4-creating-a-restful-api/4.5-creating-a-post-method/) | Create a POST method for the `/students` endpoint to call the `insertStudentData` function and store student information. |
| 4.6 | [Create Resource & Method for data backup](/4-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/) | Create a resource and POST method for the `/backup` endpoint to call the `BackupDynamoDBAndSendEmail` function. |
| 4.7 | [Enable CORS to support frontend access](/4-creating-a-restful-api/4.7-enabling-cors/) | Enable CORS to support cross-origin requests from the web interface on CloudFront. |
| 4.8 | [Deploy the API to a specific stage](/4-creating-a-restful-api/4.8-deploying-the-api/) | Deploy the API to a stage (e.g., `prod`) for use in the production environment. |
| 4.9 | [Link API Key to Usage Plan & link with REST API and Stage](/4-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/) | Link the API Key to the Usage Plan and stage to ensure only valid requests are processed. |

> **Note**: Follow the steps in order to ensure the API is configured correctly. Each step will be detailed in the corresponding documentation.

---

## Conclusion

By completing these configuration steps, you will have:  
- A RESTful API integrated with Lambda functions (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`).  
- The API secured with an API Key and Usage Plan.  
- CORS support for the web interface on CloudFront.

> **Ready to proceed?**  
> Go to [Create a new REST API on API Gateway](/4-creating-a-restful-api/4.1-creating-a-rest-api/) to start configuring the first API!
