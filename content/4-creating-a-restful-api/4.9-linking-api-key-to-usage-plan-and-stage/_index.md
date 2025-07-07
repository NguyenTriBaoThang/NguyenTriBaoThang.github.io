---
title: "Link API Key to Usage Plan & Associate with REST API and Stage"
date: 2023-10-25
weight: 9
chapter: false
pre: "<b>4.9 </b>"
---

> **Objective**: Link the `StudentApiKey` (created in section 4.2) to the `StudentUsagePlan` (created in section 4.3) and associate it with the `student` API (created in section 4.1) on the `prod` stage (created in section 4.8). This ensures that requests to the endpoints (**GET /students**, **POST /students**, **POST /backup**) must include the `StudentApiKey` in the `x-api-key` header and adhere to the limits of the `StudentUsagePlan` (Rate: 5 requests/second, Burst: 10 requests, Quota: 1000 requests/day). This configuration allows the web interface (running on CloudFront, using Tailwind CSS) to access the API securely and with control.

---

## Overview of API Key and Usage Plan in API Gateway

- **API Key** (`StudentApiKey`) is an authentication string used to control access to the API methods (**GET /students**, **POST /students**, **POST /backup**), requiring the `x-api-key` header in each request.  
- **Usage Plan** (`StudentUsagePlan`) manages access limits (Rate, Burst, Quota) and links the API Key with a specific API/stage.  
- Linking `StudentApiKey` to `StudentUsagePlan` and the `student` API on the `prod` stage ensures:  
  - Only requests with a valid `StudentApiKey` are processed.  
  - Requests adhere to the limits: 5 requests/second (Rate), 10 concurrent requests (Burst), and 1000 requests/day (Quota).  
  - The web interface can safely call the endpoints with CORS support (section 4.7) and **Invoke URL** (section 4.8).  
- After completing the steps, the endpoints will be ready for use in the web interface with API Key security.

---

## Prerequisites

{{% notice info %}}  
You need to complete the steps in section 4.1 (create the `student` API), section 4.2 (create the `StudentApiKey` API Key), section 4.3 (create the `StudentUsagePlan` Usage Plan), section 4.4 (create the **GET /students** method), section 4.5 (create the **POST /students** method), section 4.6 (create the `/backup` resource and **POST /backup** method), section 4.7 (enable CORS), section 4.8 (deploy the API to the `prod` stage), and section 3 (create the Lambda functions `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, `studentData` DynamoDB table, `student-backup-20250706` S3 bucket, SES email verification). Ensure your AWS account is ready and the AWS region is `us-east-1`.  
{{% /notice %}}

---

## Detailed Actions

1. **Access AWS Management Console**  
   - Open your browser and log in to **[AWS Management Console](https://console.aws.amazon.com)** with your AWS account.  
   - In the search bar at the top of the page, type **API Gateway** and select **Amazon API Gateway** to access the management interface.  
   - Check the AWS region: Make sure you're working in the correct AWS region (assumed `us-east-1` to match previous steps), and verify the region in the top-right corner of the AWS Console. This region must match with the `student` API, Lambda functions (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`), `studentData` DynamoDB table, `student-backup-20250706` S3 bucket, and SES.  

     ![AWS Console interface with the API Gateway search bar.](/images/5-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/linking-api-key-to-usage-plan-and-stage-01.png)  
     *Figure 1: AWS Console interface with the API Gateway search bar.*

2. **Navigate to the API Keys Section**  
   - In the main interface of Amazon API Gateway, look at the left navigation menu.  
   - Select **API Keys** to view the list of existing API Keys.  
   - The list should display `StudentApiKey` (created in section 4.2). If it's not visible, check your AWS region or refresh the page.  

     ![Navigation menu with the API Keys option.](/images/5-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/linking-api-key-to-usage-plan-and-stage-02.png)  
     *Figure 2: Navigation menu with the API Keys option.*

3. **Select the `StudentApiKey`**  
   - In the **API Keys** list, find and select `StudentApiKey`.  
   - You will be taken to the detail page of `StudentApiKey`, where you can see information like **Value** (the API key value, which may be hidden), **Usage Plans**, and configuration options.  

     ![Detail page of `StudentApiKey`.](/images/5-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/linking-api-key-to-usage-plan-and-stage-03.png)  
     *Figure 3: Detail page of `StudentApiKey`.*

4. **Link `StudentApiKey` to the Usage Plan**  
   - On the detail page of `StudentApiKey`, click **Add to Usage Plan** (or **Actions** > **Add to Usage Plan**, depending on your Console version).  
   - In the **Add key to usage plan** section:  
     - **Usage Plan**: Select `StudentUsagePlan` from the dropdown (created in section 4.3).  
     - **Note**: If `StudentUsagePlan` does not appear, check if the Usage Plan has been created in the same AWS region (`us-east-1`).  
   - Click **Save** to link `StudentApiKey` to `StudentUsagePlan`.  
   - Check: After saving, in the detail page of `StudentApiKey`, the **Usage Plans** section will show `StudentUsagePlan`.  

     ![Linking `StudentApiKey` to `StudentUsagePlan`.](/images/5-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/linking-api-key-to-usage-plan-and-stage-04.png)  
     *Figure 4: Linking `StudentApiKey` to `StudentUsagePlan`.*

5. **Check the Status of the API Key Link**  
   - After clicking **Save**, you should see the message: _"Successfully added 'StudentApiKey' to 'StudentUsagePlan'."_  
   - If you don't see the message or encounter an error:  
     - _"Usage Plan not found"_: Check if `StudentUsagePlan` exists in **Usage Plans** (section 4.3).  
     - _"AccessDenied"_: Check the IAM role of your AWS account for `apigateway:PUT` permission to link the API Key.  
     - _"API Key already added"_: If `StudentApiKey` was already linked, this message may appear; skip and continue to the next step.  

     ![Status message of linking the API Key.](/images/5-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/linking-api-key-to-usage-plan-and-stage-05.png)  
     *Figure 5: Status message of linking the API Key.*

6. **Navigate to the Usage Plans Section**  
   - In the left menu of Amazon API Gateway, select **Usage Plans** to see the list of Usage Plans.  
   - The list should display `StudentUsagePlan` (created in section 4.3). If it's not visible, check your AWS region or refresh the page.  

     ![Navigation menu with the Usage Plans option.](/images/5-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/linking-api-key-to-usage-plan-and-stage-06.png)  
     *Figure 6: Navigation menu with the Usage Plans option.*

7. **Select `StudentUsagePlan`**  
   - In the **Usage Plans** list, find and select `StudentUsagePlan`.  
   - You will be taken to the detail page of `StudentUsagePlan`, where you can see information such as **Throttling** (Rate: 5, Burst: 10), **Quota** (1000 requests/day), **API Keys**, and **Associated APIs and Stages**.  

     ![Detail page of `StudentUsagePlan`.](/images/5-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/linking-api-key-to-usage-plan-and-stage-07.png)  
     *Figure 7: Detail page of `StudentUsagePlan`.*

8. **Link API and Stage**  
   - In the detail page of `StudentUsagePlan`, click **Add API Stage** (or **Actions** > **Add API Stage**, depending on your Console version).  

   ![Clicking the Add API Stage button.](/images/5-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/linking-api-key-to-usage-plan-and-stage-08.png)  
     *Figure 8: Clicking the Add API Stage button.*

   - In the **Add API Stage** interface:  
     - **API**: Select `student` from the dropdown (created in section 4.1).  
     - **Stage**: Select `prod` from the dropdown (created in section 4.8).  
     - **Note**: If `student` or `prod` does not appear, check that the `student` API and `prod` stage have been created in the same AWS region (`us-east-1`).  
   - Click **Add to Usage Plan** to link.  
   - Check: In the detail page of `StudentUsagePlan`, the **Associated APIs and Stages** section will show `student:prod`.  

     ![Linking API and Stage interface.](/images/5-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/linking-api-key-to-usage-plan-and-stage-09.png)  
     *Figure 9: Linking API and Stage interface.*

9. **Check the Status of API and Stage Link**  
   - After clicking **Add to Usage Plan**, you should see the message: _"Successfully added stage 'prod' to usage plan."_  
   - To verify:  
     - In **Usage Plans** > `StudentUsagePlan`:  
       - Check that **API Keys** displays `StudentApiKey`.  
       - Check that **Associated APIs and Stages** displays `student:prod`.  
     - If you don't see the message or encounter an error:  
       - _"API or Stage not found"_: Check if the `student` API and `prod` stage exist (sections 4.1, 4.8).  
       - _"AccessDenied"_: Check if your IAM role has the `apigateway:PUT` permission to link API/stage.  
       - _"Stage already associated"_: If `student:prod` was already linked, this message may appear; skip.  

     ![Status message of linking API and Stage.](/images/5-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/linking-api-key-to-usage-plan-and-stage-10.png)  
     *Figure 10: Status message of linking API and Stage.*

---

## Key Considerations

| **Factor** | **Details** |
|------------|------------|
| **Check Full Configuration** | - **API Key**: `StudentApiKey` is linked to `StudentUsagePlan`. <br> - **Usage Plan**: `StudentUsagePlan` applies Rate limits (5 requests/second), Burst (10 requests), and Quota (1000 requests/day). <br> - **API/Stage**: `student:prod` is linked and applies the limits of `StudentUsagePlan` to the endpoints (**GET /students**, **POST /students**, **POST /backup**). <br> - **API Key Required**: The methods have **API Key Required: true** (sections 4.4, 4.5, 4.6). |
| **API Key Security** | Requests to the endpoints must include the `x-api-key: <StudentApiKey>` header. <br> Store the API Key in **AWS Secrets Manager** for increased security. |
| **CORS** | Ensure CORS is enabled (section 4.7) with the **OPTIONS** method and `Access-Control-Allow-Origin: '*'` header (or specific CloudFront domain). <br> Lambda functions (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`) must return the `Access-Control-Allow-Origin: '*'` header (configured in sections 3.1, 3.2, 3.3). |
| **AWS Region** | Ensure the `us-east-1` region matches with the `student` API, `prod` stage, `StudentApiKey`, `StudentUsagePlan`, Lambda functions, `studentData` DynamoDB table, `student-backup-20250706` S3 bucket, and SES. |
| **Error Handling** | - If a `403 "Forbidden"` error occurs when calling the endpoint: <br> - Check if the `StudentApiKey` is valid and linked to `StudentUsagePlan`. <br> - Ensure `student:prod` is linked to `StudentUsagePlan`. <br> - Verify **API Key Required: true** in **Method Request** (sections 4.4, 4.5, 4.6). <br> - If a `429 "Too Many Requests"` error occurs: <br> - Check Rate (5 requests/second), Burst (10 requests), or Quota (1000 requests/day) limits in `StudentUsagePlan`. <br> - Check usage statistics in **Usage Plans** > `StudentUsagePlan` > **Usage**. <br> - If a `500` error occurs from Lambda, check the logs in **CloudWatch** (`/aws/lambda/getStudentData`, `/aws/lambda/insertStudentData`, `/aws/lambda/BackupDynamoDBAndSendEmail`). <br> - If no success message appears, check your AWS region or refresh the Console page. |
| **Optimization** | - Enable **CloudWatch Metrics** for `StudentUsagePlan` to track the number of requests: <br> - In **Usage Plans** > `StudentUsagePlan`, select **Enable usage plan metrics**. <br> - Check in **CloudWatch** > **Metrics** > **API Gateway** > **UsagePlanId**. <br> - Consider using **AWS WAF** with API Gateway to protect against DDoS attacks or API Key abuse. <br> - If more API Keys are needed (e.g., for multiple web applications), create additional API Keys and link them to `StudentUsagePlan`. |
| **Early Verification** | - After linking `StudentApiKey` and associating `student:prod`, check the configuration in **Usage Plans** > `StudentUsagePlan`. <br> - Test the endpoints using Postman or curl with the `StudentApiKey`. <br> - Expected results: <br> - **GET /students**: Returns student data from DynamoDB `studentData`. <br> - **POST /students**: Stores new records in DynamoDB and sends a confirmation email via SES. <br> - **POST /backup**: Creates a backup file in S3 `student-backup-20250706` and sends a notification email. <br> - Check from the web interface (open **Developer Tools** > **Network** in your browser) to verify there are no CORS, 403, or 429 errors. |
| **Web Interface Integration Check** | Use the **Invoke URL** and `StudentApiKey` in the web interface (using Tailwind CSS, running on CloudFront) to call the endpoints (**GET /students**, **POST /students**, **POST /backup**). |

> **Best Practice Tip**: After linking `StudentApiKey` and associating `student:prod`, test the endpoints using Postman with the `x-api-key` header before integrating with the web interface. Verify the data in DynamoDB `studentData`, the S3 bucket `student-backup-20250706`, and the SES email to ensure the endpoints are working correctly.

---

## Conclusion

`StudentApiKey` has been successfully linked to `StudentUsagePlan` and associated with the `student` API on the `prod` stage, ensuring that the endpoints (**GET /students**, **POST /students**, **POST /backup**) are secured and access-controlled, ready for use in the web interface.

> **Next Step**: Proceed to [Continue configuring or integrating the web interface](5-designing-the-website-interface/) to complete the system!
