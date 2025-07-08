---
title: "Create GET Method to Retrieve Data"
date: 2023-10-25
weight: 4
chapter: false
pre: "<b>4.4. </b>"
---

> **Objective**: Create a **GET** method on the `/students` resource in the `student` API (created in section 4.1) to integrate with the `getStudentData` Lambda function (created in section 3.1), allowing the retrieval of the student list from the `studentData` DynamoDB table. The method will require an API Key (`StudentApiKey`, created in section 4.2) in the `x-api-key` header for security, and prepare for enabling CORS (section 4.7) so the web interface (running on CloudFront) can make requests.

---

## Overview of the GET Method

- The **GET /students** method will call the `getStudentData` Lambda function to fetch all records from the `studentData` DynamoDB table (fields: `studentid`, `name`, `class`, `birthdate`, `email`).  
- The `getStudentData` function will return a JSON response with the header `Access-Control-Allow-Origin: '*'` to support CORS, suitable for the web interface.  
- **API Key Required** ensures that only requests with a valid `StudentApiKey` will be processed.  
- After creation, the API needs to be deployed (section 4.8) for the **GET** method to take effect.

---

## Prerequisites

{{% notice info %}}
You need to complete section 4.1 (create the `student` API), section 4.2 (create the `StudentApiKey` API Key), section 4.3 (create the `StudentUsagePlan` Usage Plan), and section 3 (create the Lambda functions `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, the `studentData` DynamoDB table, the `student-backup-20250706` S3 bucket, SES email verification). Ensure your AWS account is set up and the AWS region is `us-east-1`.
{{% /notice %}}

---

## Detailed Steps

1. **Access AWS Management Console**  
   - Open your browser and log in to **[AWS Management Console](https://console.aws.amazon.com)** with your AWS account.  
   - In the search bar at the top, type **API Gateway** and select the **Amazon API Gateway** service to access the management interface.  
   - Check the AWS region: Ensure you're working in the primary AWS region (assumed to be `us-east-1` for synchronization with previous sections), and check the region at the top right corner of the AWS Console. This region must match the `student` API, the `getStudentData` Lambda function, the `studentData` DynamoDB table, the `student-backup-20250706` S3 bucket, and SES.

     ![creating-a-get-method-01](/images/5-creating-a-restful-api/4.4-creating-a-get-method/creating-a-get-method-01.png)
     *Figure 1: AWS Console Interface with API Gateway Search Bar.*

2. **Navigate to the APIs Section**  
   - In the main Amazon API Gateway interface, look at the left navigation menu.  
   - Select **APIs** to view the list of existing APIs.  
   - The list will show the `student` API (created in section 4.1). If not visible, check the AWS region again or refresh the page.

     ![Navigation Menu with APIs Option](/images/5-creating-a-restful-api/4.4-creating-a-get-method/creating-a-get-method-02.png)
     *Figure 2: Navigation Menu with APIs Option.*

3. **Select the `student` API**  
   - In the **APIs** list, find and select the `student` API.  
   - You'll be taken to the `student` API management page, displaying options like **Resources**, **Stages**, **API Keys**, etc.  
   - Select **Resources** from the left menu to start configuring the resource and method.

     ![API Management Page for `student` with Resources Option](/images/5-creating-a-restful-api/4.4-creating-a-get-method/creating-a-get-method-03.png)
     *Figure 3: API Management Page for `student` with Resources Option.*

4. **Create the `/students` Resource**  
   - In the **Resources** interface, you'll see the root `/`.  
   - Click **Actions** > **Create Resource** to create a new resource.  
   - Configure the resource:  
     - **Resource Name**: Enter `students`.  
     - **Resource Path**: Enter `/students` (or leave it as the default, which will automatically be `/students`).  
     - **Enable API Gateway CORS**: Select to prepare for enabling CORS (section 4.7).  
   - Click **Create Resource** to create the resource.  
   - Check: The `/students` resource will appear under the root `/` in the resource tree.

     ![Create `/students` Resource Interface](/images/5-creating-a-restful-api/4.4-creating-a-get-method/creating-a-get-method-04.png)  
     *Figure 4: Create `/students` Resource Interface.*

5. **Create the GET Method**  
   - In the resource tree, select the `/students` resource.  
   - Click **Actions** > **Create Method**.  
   - From the dropdown under `/students`, select **GET** and click the checkmark (✔) to confirm.  
   - **Note**: If the dropdown doesn't show **GET**, ensure you've selected the correct `/students` resource.  
   - **Integration Type**: Select **Lambda Function** to integrate with the Lambda function.

     ![Create GET Method Interface](/images/5-creating-a-restful-api/4.4-creating-a-get-method/creating-a-get-method-05.png)
     *Figure 5: Create GET Method Interface.*

6. **Configure Lambda Integration**  
   - In the **GET** method configuration interface:  
     - **Use Lambda Proxy integration**: Select (to send the entire HTTP request to the Lambda function and receive a JSON response with headers).  
     - **Lambda Region**: Select `us-east-1` (or your AWS region, which must match the region of the `getStudentData` function).  
     - **Lambda Function**: Enter `getStudentData`.  
       - **Note**: If the `getStudentData` function doesn't appear in the suggestion list, enter it manually and ensure the function exists in Lambda (section 3.1).  
     - Click **Save** to save the configuration.  
   - If AWS prompts for permissions, click **OK** to allow API Gateway to invoke the `getStudentData` Lambda function. AWS will automatically add the IAM policy to the Lambda function's role (usually `LambdaGetStudentRole` from section 3.1) with the `lambda:InvokeFunction` permission.

     ![Lambda Integration Configuration Interface](/images/5-creating-a-restful-api/4.4-creating-a-get-method/creating-a-get-method-06.png)
     *Figure 6: Lambda Integration Configuration Interface.*

7. **Enable API Key Requirement**  
   - In the **Method Request** interface for **GET /students**:  
     - Click **Edit** next to **Authorization**.  
     - Select **NONE** (API Key will handle authentication, no need for Cognito or IAM Authorizer).  
     - In **API Key Required**, select **true** to require the API Key in the `x-api-key` header.  
       - **Explanation**: This ensures that any requests sent to **GET /students** must include the `StudentApiKey` (created in section 4.2) in the `x-api-key` header.  
     - Click **Save** or the checkmark (✔) to save the configuration.

     ![Enable API Key Required Interface](/images/5-creating-a-restful-api/4.4-creating-a-get-method/creating-a-get-method-07.png)
     *Figure 7: Enable API Key Required Interface.*

8. **Check the Status of Method Creation**  
   - After configuring and clicking **Save**, you'll see the message: _"Successfully created method ‘GET’. Redeploy your API for the update to take effect."_  
   - **Important Note**: The **GET** method will not work until you deploy the API to a stage (section 4.8).  
   - To check the configuration:  
     - In **Resources**, select **GET** under `/students`.  
     - Verify:  
       - **Integration Request**: Displays **Lambda Function: getStudentData**.  
       - **Method Request**: **API Key Required: true**.  
     - If errors occur:  
       - _"Lambda function not found"_: Check that the `getStudentData` function exists in **Lambda** > **Functions**.  
       - _"AccessDenied"_: Check if your AWS IAM role has the `apigateway:PUT` permission to create methods.  
       - _"Permission denied"_: Ensure API Gateway has permission to invoke `getStudentData` (AWS automatically adds permission when you click **OK**).

     ![Success Message After Creating GET Method](/images/5-creating-a-restful-api/4.4-creating-a-get-method/creating-a-get-method-08.png)
     *Figure 8: Success Message After Creating GET Method.*

---

## Important Notes

| **Element** | **Details** |
|-------------|-------------|
| **Lambda Proxy Integration** | **Lambda Proxy integration** allows sending the entire HTTP request (headers, query parameters, body) to the `getStudentData` function and receiving a JSON response with headers (like `Access-Control-Allow-Origin: '*'`). <br> Ensure the `getStudentData` function (section 3.1) returns the response in the correct format. |
| **API Key Security** | With **API Key Required: true**, requests to **GET /students** must include the header `x-api-key: <StudentApiKey>`. <br> For enhanced security, store the API Key in **AWS Secrets Manager** (see section 4.2). |
| **CORS** | The **GET** method must support CORS for the web interface to make cross-origin requests. This will be configured in detail in section 4.7 (enabling CORS with the **OPTIONS** method). <br> Ensure the `getStudentData` function returns the `Access-Control-Allow-Origin: '*'` header (or a specific CloudFront domain, e.g., `https://d12345678.cloudfront.net`). |
| **AWS Region** | Ensure the `us-east-1` region matches the region of the `getStudentData` function, the `studentData` table, and the `student` API. If using a different region (e.g., `us-west-2`), select the correct region in the **Lambda Region**. |
| **Error Handling** | - If you encounter the error _"Lambda function not found"_: <br> - Check that the `getStudentData` function exists in **Lambda** > **Functions**. <br> - Ensure the AWS region matches (`us-east-1`). <br> - If you encounter a `403 "Forbidden"` error when calling the API (after deployment): <br> - Check **API Key Required: true** and ensure the `StudentApiKey` is valid. <br> - Ensure the API Key is linked to the Usage Plan (sections 4.3, 4.9). <br> - If you receive a `500` error from Lambda, check the logs in **CloudWatch** (log group `/aws/lambda/getStudentData`) for debugging. |
| **Optimization** | - Add the `Access-Control-Allow-Origin` header in the **Method Response** to ensure CORS works correctly: <br> - In **Method Response** for **GET /students**, add **Status Code 200** with the header `Access-Control-Allow-Origin: '*'`. <br> - In **Integration Response**, map the response from Lambda to return a properly formatted JSON response. <br> - Consider using **AWS WAF** with API Gateway to protect against DDoS attacks or API Key abuse. <br> - If the `studentData` table is large, ensure the `getStudentData` function handles pagination (as in the improved code from section 3.1) to avoid exceeding the Scan limit. |
| **Early Testing** | - After creating the **GET** method, verify the configuration in **Resources** > **GET /students** (**Integration Request**, **Method Request**). <br> - After deploying the API (section 4.8), test the **GET** method using Postman or curl. <br> - If you receive a `403 "Forbidden"` error, check the API Key or **API Key Required** configuration. <br> - If you receive a `500` error, check the **CloudWatch** logs for the `getStudentData` function. |
| **Web Interface Integration Testing** | After deploying the API (section 4.8) and linking the Usage Plan (section 4.9), use the API Key in the web interface (using Tailwind CSS, running on CloudFront) to call the **GET /students** endpoint. |

> **Practical Tip**: Verify the **Integration Request** and **API Key Required** configurations before deploying the API. Test the JSON response from the `getStudentData` function using Postman to ensure the student data is returned in the correct format.

---

## Conclusion

The **GET /students** method has been successfully created in the `student` API, integrated with the `getStudentData` Lambda function and requiring the `StudentApiKey` API Key, ready for deployment and use in the web interface.

> **Next step**: Go to [Create POST Method to Store Data](/4-creating-a-restful-api/4.5-creating-a-post-method/) to continue!
