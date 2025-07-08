---
title: "Configure Bucket Policy for Public Access"
date: 2023-10-25
weight: 4
chapter: false
pre: "<b>6.4. </b>"
---

> **Objective**: Configure the **Bucket Policy** for the S3 Bucket `student-management-website-2025` to allow public access (`s3:GetObject`) to the static files (`index.html`, `styles.css`, `scripts.js` from section 6.2). This ensures the static web interface (enabled with **Static Website Hosting** in section 6.3) can be accessed via the S3 endpoint or CloudFront (section 7). The **Bucket Policy** allows everyone (`Principal: *`) to read the files, supporting integration with the `student` API (stage `prod`, section 4.8) to call the **GET /students**, **POST /students**, and **POST /backup** endpoints with API Key security (`StudentApiKey`, section 4.2) and CORS (section 4.7).

---

## Overview of Bucket Policy

- **Role of Bucket Policy**:  
  - Grants public access (`s3:GetObject`) for browsers or CloudFront to read the static files (`index.html`, `styles.css`, `scripts.js`).  
  - Ensures the **Static Website Hosting** endpoint (e.g., http://student-management-website-2025.s3-website-us-east-1.amazonaws.com) serves the web interface correctly.  
  - Prepares for integration with CloudFront to provide HTTPS and high performance.  
- **Integration with the system**:  
  - The web interface calls the `student` API (section 4.8) using the **Invoke URL** (e.g., https://abc123.execute-api.us-east-1.amazonaws.com/prod) and `StudentApiKey` in the `x-api-key` header.  
  - The functions include:  
    - **POST /students**: Save records to DynamoDB `studentData` and send a confirmation email via SES.  
    - **GET /students**: Display data in the table.  
    - **POST /backup**: Create a backup file in the S3 Bucket `student-backup-20250706` (section 2.4, 6.5) and send notification emails via SES.  
  - **Bucket Policy** (section 6.4) allows public access (`s3:GetObject`) for CloudFront to retrieve the content.  
  - CloudFront (section 7) uses the S3 endpoint as the Origin to provide HTTPS and improve load times.  
  - CORS is configured (section 4.7) to support requests from the CloudFront domain (e.g., https://d12345678.cloudfront.net).  
- **Reason for granting public access**:  
  - **Static Website Hosting** requires the files in the bucket to be publicly accessible for browsers or CloudFront to load the content.  
  - The `s3:GetObject` permission is granted to `Principal: *` (everyone) to simplify, but it can be restricted with CloudFront **OAI** (see **Note**) for better security.

---

## Initial Requirements

{{% notice info %}}
You need to complete section 6.1 (create the `student-management-website-2025` bucket), section 6.2 (upload `index.html`, `styles.css`, `scripts.js`), section 6.3 (enable **Static Website Hosting**), section 5 (build the web interface), section 4.1 (create the `student` API), section 4.2 (create the `StudentApiKey`), section 4.3 (create the `StudentUsagePlan`), section 4.4 (create the **GET /students** method), section 4.5 (create the **POST /students** method), section 4.6 (create the `/backup` resource and **POST /backup** method), section 4.7 (enable CORS), section 4.8 (deploy the API to the `prod` stage), section 4.9 (link the `StudentApiKey` to `StudentUsagePlan`), section 3 (create Lambda functions `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, DynamoDB table `studentData`, `student-backup-20250706` bucket, SES email verification). Ensure your AWS account has `s3:PutBucketPolicy` permissions and the AWS region is `us-east-1`.
{{% /notice %}}

---

## Detailed Actions

1. **Access the AWS Management Console**  
   - Open your browser and log into the **[AWS Management Console](https://console.aws.amazon.com)** using your AWS account.  
   - In the search bar at the top of the page, type **S3** and select the **Amazon S3** service to enter the bucket management interface.  
   - Check the AWS region: Ensure you are working in the **us-east-1** (US East (N. Virginia)) region to sync with the `student-management-website-2025` bucket, `student` API, Lambda functions (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`), DynamoDB `studentData`, `student-backup-20250706` bucket, and SES. The region is displayed in the top right corner of the AWS Console.  
     ![AWS Console Interface with S3 Search Bar](/images/6-configuring-s3-buckets/6.4-setting-bucket-policy-for-public-access/setting-bucket-policy-for-public-access-01.png)
     *Figure 1: AWS Console Interface with the S3 search bar.*

2. **Select the `student-management-website-2025` Bucket**  
   - In the main **Amazon S3 > Buckets** interface, find and select the `student-management-website-2025` bucket (created in section 6.1).  
   - If you cannot find the bucket:  
     - Check the AWS region (`us-east-1`) and refresh the page.  
     - Verify that the bucket has been created with the correct name (the bucket name is globally unique, so you may have used a different name such as `student-management-website-20250706-abc123`).  
   - Click on the bucket name to enter the **Bucket Management** interface.  
     ![Select `student-management-website-2025` Bucket](/images/6-configuring-s3-buckets/6.4-setting-bucket-policy-for-public-access/setting-bucket-policy-for-public-access-02.png)
     *Figure 2: Select the `student-management-website-2025` bucket.*

3. **Access the Permissions Tab**  
   - In the **student-management-website-2025** bucket interface, select the **Permissions** tab (usually located at the top of the page, next to Objects, Properties, etc.).  
   - Scroll down to the **Bucket policy** section to see the current status (it will be empty by default if not yet configured).  
     ![Permissions Tab and Bucket Policy Section](/images/6-configuring-s3-buckets/6.4-setting-bucket-policy-for-public-access/setting-bucket-policy-for-public-access-03.png)
     *Figure 3: Permissions Tab and Bucket Policy Section.*

4. **Edit the Bucket Policy**  
   - In the **Bucket policy** section, click the **Edit** button to open the configuration interface.  
   - Before editing:  
     - Ensure **Block all public access** is unchecked (section 6.1) to allow public access configuration.  
     - Verify that the files `index.html`, `styles.css`, `scripts.js` have been uploaded (section 6.2) and that **Static Website Hosting** is enabled with `index.html` as the **Index document** (section 6.3).  
     ![Click Edit in Bucket Policy](/images/6-configuring-s3-buckets/6.4-setting-bucket-policy-for-public-access/setting-bucket-policy-for-public-access-04.png)
     *Figure 4: Click Edit in Bucket Policy.*

5. **Edit the Bucket Policy JSON**  
   - In the **Edit bucket policy** interface, remove any existing content (if any) and paste the following JSON policy:  
     ```json
     {
         "Version": "2012-10-17",
         "Statement": [
             {
                 "Sid": "PublicReadGetObject",
                 "Effect": "Allow",
                 "Principal": "*",
                 "Action": "s3:GetObject",
                 "Resource": "arn:aws:s3:::student-management-website-2025/*"
             }
         ]
     }
     ```  
   - **Explanation of the JSON policy**:  
     - **Version**: "2012-10-17" is the latest IAM policy version.  
     - **Statement**: A list of permission policies.  
     - **Sid**: "PublicReadGetObject" is an optional identifier for the policy.  
     - **Effect**: "Allow" grants the specified action.  
     - **Principal**: "*" allows everyone (including browsers and CloudFront) to access.  
     - **Action**: "s3:GetObject" allows reading files in the bucket.  
     - **Resource**: "arn:aws:s3:::student-management-website-2025/*" specifies all files in the `student-management-website-2025` bucket.  
   - Verify the bucket name in the **Resource** matches `student-management-website-2025`.  
     ![Configuring Bucket Policy](/images/6-configuring-s3-buckets/6.4-setting-bucket-policy-for-public-access/setting-bucket-policy-for-public-access-05.png)
     *Figure 5: Configuring the Bucket Policy.*

6. **Save Changes**  
   - Click **Save changes** to apply the **Bucket Policy**.  
   - Expected result: AWS S3 will display the message _"Successfully edited bucket policy"_.  
     ![Click Save Changes](/images/6-configuring-s3-buckets/6.4-setting-bucket-policy-for-public-access/setting-bucket-policy-for-public-access-06.png)
     *Figure 6: Click Save Changes.*  
   - **Error Handling**:  
     - **"Policy has invalid resource"**: Check the ARN in the **Resource** is correctly formatted (`arn:aws:s3:::student-management-website-2025/*`).  
     - **"AccessDenied"**:  
       - Check the IAM role for your account has `s3:PutBucketPolicy` permissions:  
         ```json
         {
             "Version": "2012-10-17",
             "Statement": [
                 {
                     "Effect": "Allow",
                     "Action": "s3:PutBucketPolicy",
                     "Resource": "arn:aws:s3:::student-management-website-2025"
                 }
             ]
         }
         ```  
       - Ensure **Block all public access** is unchecked (section 6.1).  

7. **Test Website Access**  
   - Go back to the **Properties > Static website hosting** tab in the `student-management-website-2025` bucket.  
   - Copy the **Bucket website endpoint** (e.g., http://student-management-website-2025.s3-website-us-east-1.amazonaws.com).  
     ![Bucket Website Endpoint](/images/6-configuring-s3-buckets/6.4-setting-bucket-policy-for-public-access/setting-bucket-policy-for-public-access-07.png)
     *Figure 7: Bucket Website Endpoint.*  
   - Open your browser and go to this endpoint.  
   - Expected result:  
     - The web interface should display with the input form, student table, and functional buttons (Save, View, Backup) using Tailwind CSS and Poppins font.  
     - The `styles.css` and `scripts.js` files should load correctly, and the interface should display as expected.  
     ![Web Interface Displayed via S3 Endpoint](/images/6-configuring-s3-buckets/6.4-setting-bucket-policy-for-public-access/setting-bucket-policy-for-public-access-08.png)
     *Figure 8: Web Interface Displayed via S3 Endpoint.*  
   - **Note**:  
     - API requests (**GET /students**, **POST /students**, **POST /backup**) may encounter CORS errors because the S3 endpoint uses HTTP and has not yet integrated with CloudFront. This will be addressed when configuring CloudFront (section 7) and CORS in API Gateway (section 4.7).  
     - The S3 endpoint only supports HTTP. CloudFront will provide HTTPS and improve loading times.  
   - **Error Handling**:  
     - **403 Forbidden**:  
       - Check the **Bucket Policy** for the correct ARN (`arn:aws:s3:::student-management-website-2025/*`).  
       - Verify **Block all public access** is unchecked (section 6.1).  
       - Ensure the files `index.html`, `styles.css`, and `scripts.js` are uploaded with `public-read` permission (section 6.2) or covered by **Bucket Policy**.  
     - **404 Not Found**:  
       - Verify `index.html` is uploaded in the root directory (section 6.2).  
       - Check that **Static Website Hosting** is enabled with `index.html` as the **Index document** (section 6.3).  
     - **Incorrect Interface Display**:  
       - Check **Developer Tools > Console** in the browser to check for errors (e.g., CSS/JS files not loading).  
       - Verify paths in `index.html` (e.g., ``<link href="styles.css">``, ``<script src="scripts.js">``).  

---

## Important Notes

| Factor | Details |
|--------|---------|
| **Security** | Public access (`Principal: "*"`) is suitable for initial testing, but not secure for production. Use CloudFront **Origin Access Identity (OAI)**: <br> - Create an OAI in CloudFront > Origin access identities, and attach it to the CloudFront distribution (section 7). <br> - Re-enable **Block public access** (except for **Block public access for bucket policies**) after configuring OAI. <br> - Avoid embedding `StudentApiKey` in `scripts.js`. Use AWS Secrets Manager or CloudFront Functions: <br> function handler(event) { var request = event.request; request.headers['x-api-key'] = { value: 'xxxxxxxxxxxxxxxxxxxx' }; return request; } |
| **Optimization** | Enable **S3 Access Logs**: In S3 > student-management-website-2025 > Properties > Server access logging, select **Enable**, and specify a log bucket (e.g., student-web-logs-20250706). Use AWS CLI: <br> aws s3api put-bucket-policy --bucket student-management-website-2025 --policy file://policy.json |
| **System Integration** | Integrate with CloudFront (section 7): <br> - Use the **Bucket website endpoint** as the Origin. <br> - Set **Default root object**: `index.html`. <br> - Configure **Viewer protocol policy**: Redirect HTTP to HTTPS. <br> Update CORS in API Gateway (section 4.7) with `Access-Control-Allow-Origin: https://d12345678.cloudfront.net`. |
| **Integration Testing** | Access the **Bucket website endpoint** to test the interface. After configuring CloudFront, access the CloudFront URL (https://d12345678.cloudfront.net) and check: <br> - **POST /students**: Save records to DynamoDB `studentData`, send email via SES. <br> - **GET /students**: Display table. <br> - **POST /backup**: Create file in `student-backup-20250706`, send email. <br> Use **Developer Tools > Network** to check API requests. |
| **Error Handling** | **403 Forbidden**: Check **Bucket Policy** ARN, **Block all public access** (section 6.1), and `public-read` permission for files (section 6.2). **404 Not Found**: Verify `index.html` is in the root folder, **Static Website Hosting** is enabled with `index.html` as the **Index document** (section 6.3). **Incorrect Interface**: Check **Developer Tools > Console**, paths in `index.html`. **CORS**: Check `Access-Control-Allow-Origin` header in Lambda (sections 3.1, 3.2, 3.3) and API Gateway (section 4.7). **429**: Check rate/burst/quota limits in `StudentUsagePlan` (section 4.3). |

> **Best Practice Tip**: Test the **Bucket website endpoint** immediately after saving the **Bucket Policy**. Use AWS CLI to automate if applying policies to multiple buckets. Prepare for section 7 (CloudFront configuration) to improve security and support HTTPS.

---

## Conclusion

The **Bucket Policy** has been configured for the `student-management-website-2025` bucket, allowing public access (`s3:GetObject`) to serve the web interface. The bucket is now ready to integrate with CloudFront (section 7) for HTTPS and high performance.

> **Next step**: Proceed to [Configure CloudFront for Content Distribution](/7-configuring-cloudfront/) to continue configuring!
