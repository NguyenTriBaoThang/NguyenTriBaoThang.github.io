---
title: "Create POST Method to Store Data"
date: 2025-07-09
weight: 5
chapter: false
pre: "<b>4.5. </b>"
---

> **Objective**: Create a **POST** method on the `/students` resource in the `student` API (created in section 4.1) to integrate with the `insertStudentData` Lambda function (created in section 3.2), allowing student information to be stored in the `studentData` DynamoDB table and a confirmation email to be sent via SES. The method will require an API Key (`StudentApiKey`, created in section 4.2) in the `x-api-key` header for security and prepare for enabling CORS (section 4.7) so the web interface (running on CloudFront) can make requests.

---

## Overview of the POST Method

- The **POST /students** method will call the `insertStudentData` Lambda function to store a student record (fields: `studentid`, `name`, `class`, `birthdate`, `email`) into the `studentData` DynamoDB table and send a confirmation email via SES.  
- The `insertStudentData` function will return a JSON response with the header `Access-Control-Allow-Origin: '*'` to support CORS, suitable for the web interface.  
- **API Key Required** ensures that only requests with a valid `StudentApiKey` will be processed.  
- After creation, the API needs to be deployed (section 4.8) for the **POST** method to take effect.

---

## Prerequisites

{{% notice info %}}
You need to complete section 4.1 (create the `student` API), section 4.2 (create the `StudentApiKey` API Key), section 4.3 (create the `StudentUsagePlan` Usage Plan), section 4.4 (create the **GET /students** method), and section 3 (create the Lambda functions `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, the `studentData` DynamoDB table, the `student-backup-20250706` S3 bucket, SES email verification). Ensure your AWS account is set up and the AWS region is `us-east-1`.
{{% /notice %}}

---

## Detailed Steps

1. **Access AWS Management Console**  
   - Open your browser and log in to **[AWS Management Console](https://console.aws.amazon.com)** with your AWS account.  
   - In the search bar at the top, type **API Gateway** and select the **Amazon API Gateway** service to access the management interface.  
   - Check the AWS region: Ensure you're working in the primary AWS region (assumed to be `us-east-1` for synchronization with previous sections), and check the region at the top right corner of the AWS Console. This region must match the `student` API, the `insertStudentData` Lambda function, the `studentData` DynamoDB table, the `student-backup-20250706` S3 bucket, and SES.

     ![AWS Console Interface with API Gateway Search Bar](/images/5-creating-a-restful-api/4.5-creating-a-post-method/creating-a-post-method-01.png)
     *Figure 1: AWS Console Interface with API Gateway Search Bar.*

2. **Navigate to the APIs Section**  
   - In the main Amazon API Gateway interface, look at the left navigation menu.  
   - Select **APIs** to view the list of existing APIs.  
   - The list will show the `student` API (created in section 4.1). If not visible, check the AWS region again or refresh the page.

     ![Navigation Menu with APIs Option](/images/5-creating-a-restful-api/4.5-creating-a-post-method/creating-a-post-method-02.png)
     *Figure 2: Navigation Menu with APIs Option.*

3. **Select the `student` API**  
   - In the **APIs** list, find and select the `student` API.  
   - You'll be taken to the `student` API management page, displaying options like **Resources**, **Stages**, **API Keys**, etc.  
   - Select **Resources** from the left menu to continue configuring the resource and method.

     ![API Management Page for `student` with Resources Option](/images/5-creating-a-restful-api/4.5-creating-a-post-method/creating-a-post-method-03.png)
     *Figure 3: API Management Page for `student` with Resources Option.*

4. **Use the `/students` Resource**  
   - In the **Resources** interface, you will see the root `/` and the `/students` resource (created in section 4.4 for the **GET** method).  
   - If the `/students` resource doesn't exist:  
     - Click **Actions** > **Create Resource**.  
     - Configure the resource:  
       - **Resource Name**: Enter `students`.  
       - **Resource Path**: Enter `/students` (or leave the default, which will automatically be `/students`).  
       - **Enable API Gateway CORS**: Select to prepare for enabling CORS (section 4.7).  
     - Click **Create Resource** to create it.  
   - Select the `/students` resource in the resource tree to create the **POST** method.

     ![Use `/students` Resource Interface](/images/5-creating-a-restful-api/4.5-creating-a-post-method/creating-a-post-method-04.png)
     *Figure 4: Use `/students` Resource Interface.*

5. **Create the POST Method**  
   - In the resource tree, select the `/students` resource.  
   - Click **Actions** > **Create Method**.  
   - From the dropdown under `/students`, select **POST** and click the checkmark (✔) to confirm.  
   - **Note**: If the dropdown doesn't show **POST**, ensure you've selected the correct `/students` resource.  
   - In the **POST method configuration** interface:  
     - **Integration Type**: Select **Lambda Function** to integrate with the Lambda function.  
     - **Use Lambda Proxy integration**: Select (to send the entire HTTP request, including headers and body, to the Lambda function and receive a JSON response with headers).  
     - **Lambda Region**: Select `us-east-1` (or your AWS region, which must match the region of the `insertStudentData` function).  
     - **Lambda Function**: Enter `insertStudentData`.  
       - **Note**: If the `insertStudentData` function doesn't appear in the suggestion list, enter it manually and ensure the function exists in Lambda (section 3.2).  
     - Click **Save** to save the configuration.  
   - If AWS prompts for permissions, click **OK** to allow API Gateway to invoke the `insertStudentData` Lambda function. AWS will automatically add the IAM policy to the Lambda function's role (usually `LambdaInsertStudentRole` from section 3.2) with the `lambda:InvokeFunction` permission.

     ![Create POST Method Interface](/images/5-creating-a-restful-api/4.5-creating-a-post-method/creating-a-post-method-05.png)
     *Figure 5: Create POST Method Interface.*

6. **Enable API Key Required**  
   - In the **Method Request** interface for **POST /students**:  
     - Click **Edit** next to **Authorization**.  
     - Select **NONE** (API Key will handle authentication, no need for Cognito or IAM Authorizer).  
     - In **API Key Required**, select **true** to require the API Key in the `x-api-key` header.  
       - **Explanation**: This ensures that any request sent to **POST /students** must include the `StudentApiKey` (created in section 4.2) in the `x-api-key` header.  
     - Click **Save** or the checkmark (✔) to save the configuration.

     ![Enable API Key Required Interface](/images/5-creating-a-restful-api/4.5-creating-a-post-method/creating-a-post-method-06.png)
    *Figure 6: Enable API Key Required Interface.*

7. **Check the Status of Method Creation**  
   - After configuring and clicking **Save**, you'll see the message: _"Successfully created method ‘POST’. Redeploy your API for the update to take effect."_  
   - **Important Note**: The **POST** method will not work until you deploy the API to a stage (section 4.8).  
   - To check the configuration:  
     - In **Resources**, select **POST** under `/students`.  
     - Verify:  
       - **Integration Request**: Displays **Lambda Function: insertStudentData**.  
       - **Method Request**: **API Key Required: true**.  
     - If errors occur:  
       - _"Lambda function not found"_: Check that the `insertStudentData` function exists in **Lambda** > **Functions** and the AWS region matches (`us-east-1`).  
       - _"AccessDenied"_: Check if your AWS IAM role has the `apigateway:PUT` permission to create methods.  
       - _"Permission denied"_: Ensure API Gateway has permission to invoke `insertStudentData` (AWS automatically adds permission when you click **OK**).

     ![Success Message After Creating POST Method](/images/5-creating-a-restful-api/4.5-creating-a-post-method/creating-a-post-method-07.png)
     - *Figure 7: Success Message After Creating POST Method.*

---

## Important Notes

| **Element** | **Details** |
|-------------|-------------|
| **Lambda Proxy Integration** | **Lambda Proxy integration** allows sending the entire HTTP request (headers, body) to the `insertStudentData` function and receiving a JSON response with headers (like `Access-Control-Allow-Origin: '*'`). <br> Ensure the `insertStudentData` function (section 3.2) correctly handles the input JSON format and returns a valid response. |
| **API Key Security** | With **API Key Required: true**, requests to **POST /students** must include the header `x-api-key: <StudentApiKey>`. <br> For enhanced security, store the API Key in **AWS Secrets Manager** (see section 4.2). |
| **CORS** | The **POST** method must support CORS for the web interface to make cross-origin requests. This will be configured in detail in section 4.7 (enabling CORS with the **OPTIONS** method). <br> Ensure the `insertStudentData` function returns the `Access-Control-Allow-Origin: '*'` header (or a specific CloudFront domain, e.g., `https://d12345678.cloudfront.net`). |
| **AWS Region** | Ensure the `us-east-1` region matches the `insertStudentData` function, the `studentData` table, SES, and the `student` API. If using a different region (e.g., `us-west-2`), select the correct region in the **Lambda Region**. |
| **Error Handling** | - If you encounter the error _"Lambda function not found"_: <br> - Check that the `insertStudentData` function exists in **Lambda** > **Functions**. <br> - Ensure the AWS region matches (`us-east-1`). <br> - If you encounter a `403 "Forbidden"` error when calling the API (after deployment): <br> - Check **API Key Required: true** and ensure the `StudentApiKey` is valid. <br> - Ensure the API Key is linked to the Usage Plan (sections 4.3, 4.9). <br> - If you encounter `400`, `409`, or `500` errors from Lambda, check the logs in **CloudWatch** (log group `/aws/lambda/insertStudentData`) for debugging: <br> - `400`: Invalid JSON body (missing `studentid`, `name`, etc.). <br> - `409`: `studentid` already exists (due to **ConditionExpression**). <br> - `500`: DynamoDB or SES error (e.g., email not verified in SES). |
| **Optimization** | - Add the `Access-Control-Allow-Origin` header in **Method Response** to ensure CORS works correctly: <br> - In **Method Response** for **POST /students**, add **Status Code 200, 400, 409, 500** with the header `Access-Control-Allow-Origin: '*'`. <br> - In **Integration Response**, map the response from Lambda to handle status codes. <br> - Consider using **AWS WAF** with API Gateway to protect against DDoS attacks or API Key abuse. <br> - If input validation is needed, add a **Request Validator** in **Method Request** to check the JSON body for required fields (`studentid`, `name`, `class`, `birthdate`, `email`). |
| **Early Testing** | - After creating the **POST** method, verify the configuration in **Resources** > **POST /students** (**Integration Request**, **Method Request**). <br> - After deploying the API (section 4.8), test the **POST** method using Postman or curl. <br> - Check the `studentData` DynamoDB table (go to **DynamoDB** > **Tables** > `studentData` > **Explore items**) to verify the new record. <br> - Check the recipient's mailbox (including Spam/Junk) for the confirmation email from SES (e.g., `student4@example.com`). <br> - If you encounter a `403 "Forbidden"` error, check the API Key and **API Key Required** configuration. <br> - If you encounter `400`, `409`, or `500` errors, check the **CloudWatch** logs for the `insertStudentData` function. |
| **Web Interface Integration Testing** | After deploying the API (section 4.8) and linking the Usage Plan (section 4.9), use the API Key in the web interface (using Tailwind CSS, running on CloudFront) to call the **POST /students** endpoint. |

> **Practical Tip**: Verify the **Integration Request** and **API Key Required** configurations before deploying the API. Test the data in the `studentData` table and the confirmation email from SES using Postman to ensure the `insertStudentData` function works correctly.

---

## Conclusion

The **POST /students** method has been successfully created in the `student` API, integrated with the `insertStudentData` Lambda function and requiring the `StudentApiKey` API Key, ready for deployment and use in the web interface.

> **Next step**: Go to [Create Resource & Method for Backup Feature](/4-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/) to continue!
