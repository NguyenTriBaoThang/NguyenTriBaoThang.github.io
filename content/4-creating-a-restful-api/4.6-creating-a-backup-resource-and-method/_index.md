---
title: "Create Resource and Method for Data Backup"
date: 2023-10-25
weight: 6
chapter: false
pre: "<b>4.6. </b>"
---

> **Objective**: Create the resource `/backup` and the **POST** method in the `student` API (created in section 4.1) to integrate with the Lambda function `BackupDynamoDBAndSendEmail` (created in section 3.3). This will allow backing up all data from the DynamoDB `studentData` table to the S3 bucket `student-backup-20250706` and sending an email notification via SES. The method will require an API Key (`StudentApiKey`, created in section 4.2) in the `x-api-key` header for security, and prepare for enabling CORS (section 4.7) so that the web interface (running on CloudFront) can send requests.

---

## Overview of the Resource and POST Method

- The `/backup` resource and **POST /backup** method will invoke the Lambda function `BackupDynamoDBAndSendEmail` to:  
  - Back up all records from the DynamoDB `studentData` table (fields: `studentid`, `name`, `class`, `birthdate`, `email`) into a JSON file in the S3 bucket `student-backup-20250706`.  
  - Send an email notification via SES to a designated address (e.g., admin or a user).  
- The `BackupDynamoDBAndSendEmail` function returns a JSON response with the header `Access-Control-Allow-Origin: '*'` to support CORS, suitable for the web interface.  
- **API Key Required** ensures that only requests with a valid `StudentApiKey` will be processed.  
- After creation, the API needs to be deployed (section 4.8) for the **POST** method to take effect.

---

## Prerequisites

{{% notice info %}}  
You need to complete section 4.1 (create `student` API), section 4.2 (create `StudentApiKey`), section 4.3 (create `StudentUsagePlan`), section 4.4 (create **GET /students** method), section 4.5 (create **POST /students** method), and section 3 (create Lambda functions `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, DynamoDB `studentData` table, S3 bucket `student-backup-20250706`, SES email verification). Ensure that your AWS account is set up and the AWS region is `us-east-1`.  
{{% /notice %}}

---

## Detailed Actions

1. **Access AWS Management Console**  
   - Open your browser and log into the **[AWS Management Console](https://console.aws.amazon.com)** with your AWS account.  
   - In the search bar at the top, type **API Gateway** and select the **Amazon API Gateway** service to access the management interface.  
   - Check the AWS region: Make sure you are working in the primary AWS region (assumed `us-east-1` for synchronization with previous sections), check the region in the top-right corner of the AWS Console. This region must match the `student` API, the `BackupDynamoDBAndSendEmail` Lambda function, `studentData` DynamoDB table, `student-backup-20250706` S3 bucket, and SES.

     ![AWS Console Interface with API Gateway search bar.](/images/5-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/creating-a-backup-resource-and-method-01.png)  
     *Figure 1: AWS Console interface with the API Gateway search bar.*

2. **Navigate to APIs**  
   - In the main interface of Amazon API Gateway, look at the left navigation menu.  
   - Select **APIs** to view the list of existing APIs.  
   - The list should display the `student` API (created in section 4.1). If not, check the AWS region again or refresh the page.

     ![Navigation menu with APIs option.](/images/5-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/creating-a-backup-resource-and-method-02.png)  
     *Figure 2: Navigation menu with the APIs option.*

3. **Select the student API**  
   - In the **APIs** list, find and select the `student` API.  
   - You will be redirected to the API management page for `student`, showing options like **Resources**, **Stages**, **API Keys**, etc.  
   - Select **Resources** from the left menu to start configuring the resource and method.

     ![Student API management page with Resources option.](/images/5-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/creating-a-backup-resource-and-method-03.png)  
     *Figure 3: Student API management page with the Resources option.*

4. **Create the /backup Resource**  
   - In the **Resources** interface, you will see a resource tree with the root `/` and the `/students` resource (created in section 4.4).  
   - Click **Actions** > **Create Resource** to create a new resource.  
   - Configure the resource:  
     - **Resource Name**: Enter `backup`.  
     - **Resource Path**: Enter `/backup` (or leave it as default, it will automatically be `/backup`).  
     - **Enable API Gateway CORS**: Select to prepare for enabling CORS (section 4.7).  
   - Click **Create Resource** to create it.  
   - Check: The `/backup` resource will appear under the root `/` in the resource tree.

     ![Click the Create button.](/images/5-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/creating-a-backup-resource-and-method-04.png)  
     *Figure 4: Click the Create button.*

     ![Resource configuration interface for /backup.](/images/5-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/creating-a-backup-resource-and-method-05.png)  
     *Figure 5: Resource configuration interface for /backup.*

5. **Create the POST Method**  
   - In the resource tree, select the `/backup` resource.  
   - Click **Actions** > **Create Method**.  
   - In the dropdown below `/backup`, select **POST** and click the check mark (✔) to confirm.  
   - **Note**: If the dropdown doesn't show **POST**, ensure you have selected the correct resource `/backup`.

     ![Create POST method interface.](/images/5-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/creating-a-backup-resource-and-method-06.png)  
     *Figure 6: Create POST method interface.*

6. **Configure Lambda Integration**  
   - In the **POST** method configuration interface:  
     - **Integration Type**: Choose **Lambda Function** to integrate with the Lambda function.  
     - **Use Lambda Proxy integration**: Select (to send the entire HTTP request, including headers and body, to the Lambda function and receive a JSON response with headers).  
     - **Lambda Region**: Select `us-east-1` (or your AWS region, it must match the region of the `BackupDynamoDBAndSendEmail` Lambda).  
     - **Lambda Function**: Enter `BackupDynamoDBAndSendEmail`.  
       - **Note**: If the `BackupDynamoDBAndSendEmail` function does not appear in the suggestions list, enter it manually and ensure the function exists in Lambda (section 3.3).  
     - Click **Save** to save the configuration.  
   - If AWS asks for permissions, click **OK** to allow API Gateway to invoke the `BackupDynamoDBAndSendEmail` Lambda function. AWS will automatically add the appropriate IAM policy to the Lambda function's role (typically `DynamoDBBackupRole` from section 3.3) with the `lambda:InvokeFunction` permission.

     ![Lambda integration configuration interface.](/images/5-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/creating-a-backup-resource-and-method-07.png)  
     *Figure 7: Lambda integration configuration interface.*

     ![Click the Save button after configuration.](/images/5-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/creating-a-backup-resource-and-method-08.png)  
     *Figure 8: Click the Save button after configuration.*

7. **Enable API Key Required**  
   - In the **Method Request** interface of **POST /backup**:  
     - Click **Edit** next to **Authorization**.  
     - Select **NONE** (API Key will handle authentication, no need for Cognito or IAM Authorizer).  
     - In **API Key Required**, select **true** to require the API Key in the `x-api-key` header.  
       - **Explanation**: This ensures that all requests to **POST /backup** must include the `StudentApiKey` (created in section 4.2) in the `x-api-key` header.  
     - Click **Save** or the check mark (✔) to save the configuration.

     ![Enable API Key Required interface.](/images/5-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/creating-a-backup-resource-and-method-09.png)  
     *Figure 9: Enable API Key Required interface.*

8. **Check the Method Creation Status**  
   - After configuring and clicking **Save**, you will see the message: _"Successfully created method ‘POST’. Redeploy your API for the update to take effect."_  
   - **Important Note**: The **POST** method will not work until you deploy the API to a stage (section 4.8).  
   - To verify the configuration:  
     - In **Resources**, select **POST** under `/backup`.  
     - Verify:  
       - **Integration Request**: Shows **Lambda Function: BackupDynamoDBAndSendEmail**.  
       - **Method Request**: **API Key Required: true**.  
     - If you encounter errors:  
       - _"Lambda function not found"_: Check that the `BackupDynamoDBAndSendEmail` function exists in **Lambda** > **Functions** and that the AWS region matches (`us-east-1`).  
       - _"AccessDenied"_: Check that the IAM role of the AWS account has the `apigateway:PUT` permission to create the method.  
       - _"Permission denied"_: Ensure that API Gateway has permission to call `BackupDynamoDBAndSendEmail` (AWS will automatically add permissions when you click **OK**).

     ![Success message after creating the POST method.](/images/5-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/creating-a-backup-resource-and-method-10.png)  
     *Figure 10: Success message after creating the POST method.*

---

## Important Notes

| **Factor** | **Details** |
|------------|------------|
| **Lambda Proxy Integration** | **Lambda Proxy integration** allows sending the entire HTTP request (headers, body) to the `BackupDynamoDBAndSendEmail` function and receiving a JSON response with headers (such as `Access-Control-Allow-Origin: '*'`). <br> Ensure that the `BackupDynamoDBAndSendEmail` function (section 3.3) properly handles the backup and email sending. |
| **API Key Security** | With **API Key Required: true**, requests sent to **POST /backup** must include the `x-api-key: <StudentApiKey>` header. <br> To enhance security, store the API Key in **AWS Secrets Manager** (see section 4.2). |
| **CORS** | The **POST** method needs to support CORS for the web interface to send cross-origin requests. This will be detailed in section 4.7 (enable CORS with the **OPTIONS** method). <br> Ensure the `BackupDynamoDBAndSendEmail` function returns the header `Access-Control-Allow-Origin: '*'` (or a specific CloudFront domain, e.g., `https://d12345678.cloudfront.net`). |
| **AWS Region** | Ensure the region `us-east-1` matches the `BackupDynamoDBAndSendEmail` function, `studentData` DynamoDB table, `student-backup-20250706` S3 bucket, SES, and the `student` API. If using a different region (e.g., `us-west-2`), select the correct region in **Lambda Region**. |
| **Error Handling** | - If you get the error _"Lambda function not found"_: <br> - Check that the `BackupDynamoDBAndSendEmail` function exists in **Lambda** > **Functions**. <br> - Ensure the AWS region matches (`us-east-1`). <br> - If you get a `403 "Forbidden"` error when calling the API (after deploying): <br> - Check that **API Key Required: true** and the `StudentApiKey` API Key are valid. <br> - Ensure the API Key is linked to the Usage Plan (section 4.3, 4.9). <br> - If you get a `500` error from Lambda, check the logs in **CloudWatch** (log group `/aws/lambda/BackupDynamoDBAndSendEmail`) to debug: <br> - `NoSuchBucket`: Check that the S3 bucket `student-backup-20250706` exists. <br> - `AccessDenied`: Check that the `DynamoDBBackupRole` role has the `s3:PutObject`, `dynamodb:Scan`, and `ses:SendEmail` permissions. <br> - `Email address not verified`: Check that the source email (`no-reply@system.edu.vn`) and the recipient email (`admin@system.edu.vn`) are verified in SES (section 2.5). |
| **Optimization** | - Add the header `Access-Control-Allow-Origin` in **Method Response** to ensure CORS works correctly: <br> - In the **Method Response** for **POST /backup**, add **Status Code 200, 500** with the header `Access-Control-Allow-Origin: '*'`. <br> - In the **Integration Response**, map the response from Lambda to handle status codes. <br> - Consider using **AWS WAF** with API Gateway to protect against DDoS attacks or API Key abuse. <br> - If the `studentData` table is large, ensure that the `BackupDynamoDBAndSendEmail` function handles pagination for the Scan (e.g., using `LastEvaluatedKey`) to avoid exceeding limits. |
| **Early Testing** | - After creating the **POST** method, verify the configuration in **Resources** > **POST /backup** (**Integration Request**, **Method Request**). <br> - After deploying the API (section 4.8), test the **POST** method with Postman or curl. <br> - Check the S3 bucket `student-backup-20250706` (go to **S3** > **Buckets** > `student-backup-20250706` > **Objects**) to verify the backup file (e.g., `backup-20250707-124500.json`). <br> - Check the inbox (including Spam/Junk) of the recipient email (e.g., `admin@system.edu.vn`) to verify the email notification from SES. <br> - If you receive a `403 "Forbidden"` error, check the API Key and **API Key Required** configuration. <br> - If you receive a `500` error, check the **CloudWatch** logs of the `BackupDynamoDBAndSendEmail` function. |
| **Web Interface Integration Testing** | After deploying the API (section 4.8) and linking the Usage Plan (section 4.9), use the API Key in the web interface (using Tailwind CSS, running on CloudFront) to call the **POST /backup** endpoint. |

> **Practical Tip**: Verify the **Integration Request** and **API Key Required** configurations before deploying the API. Test the backup file in the `student-backup-20250706` S3 bucket and the email notification from SES using Postman to ensure the `BackupDynamoDBAndSendEmail` function works properly.

---

## Conclusion

The `/backup` resource and **POST /backup** method have been successfully created in the `student` API, integrated with the `BackupDynamoDBAndSendEmail` Lambda function, and require the `StudentApiKey` API Key, ready to be deployed and used in the web interface.

> **Next step**: Move to [Enable CORS to support the web interface](/4-creating-a-restful-api/4.7-enabling-cors/) to continue!
