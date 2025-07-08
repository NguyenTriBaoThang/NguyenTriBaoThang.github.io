---
title: "Configure Default Root Object"
date: 2023-10-25
weight: 2
chapter: false
pre: "<b>7.2. </b>"
---

> **Objective**: Configure `index.html` as the **Default Root Object** for the CloudFront Distribution `StudentWebsiteDistribution` (section 7.1) so that CloudFront automatically serves the `index.html` file from the S3 Bucket `student-management-website-2025` when users access the CloudFront domain (e.g., https://d12345678.cloudfront.net). This ensures the static web interface (form, student table, functional buttons) displays correctly and integrates with the `student` API (stage `prod`, section 4.8) to perform functions like saving, viewing, and backing up data.

---

## Overview of Default Root Object

- **Role of Default Root Object**:  
  - Specifies the default file (`index.html`) that CloudFront returns when users access the root URL of the distribution (e.g., https://d12345678.cloudfront.net).  
  - Similar to the **Index document** in S3 **Static Website Hosting** (section 6.3), but applied at the CloudFront layer.  
  - Ensures the main interface displays without the need for a specific path (e.g., /index.html).  
- **Integration with the system**:  
  - CloudFront distributes static files (`index.html`, `styles.css`, `scripts.js`, section 6.2) from the S3 Bucket `student-management-website-2025` (sections 6.1–6.4) via **Origin Access Identity (OAI)** (section 7.1) to restrict access.  
  - The web interface calls the `student` API (section 4.8) with the **Invoke URL** (e.g., https://abc123.execute-api.us-east-1.amazonaws.com/prod) and `StudentApiKey` (section 4.2).  
  - The functions include:  
    - **POST /students**: Save records to DynamoDB `studentData` and send a confirmation email via SES.  
    - **GET /students**: Display data in the table.  
    - **POST /backup**: Create a file in the S3 Bucket `student-backup-20250706` (section 6.5) and send notification emails via SES.  
  - CORS is configured (section 4.7) to support requests from the CloudFront domain (e.g., https://d12345678.cloudfront.net).

---

## Initial Requirements

{{% notice info %}}
You need to complete section 7.1 (create the CloudFront Distribution `StudentWebsiteDistribution`), section 6.1 (create the `student-management-website-2025` bucket), section 6.2 (upload `index.html`, `styles.css`, `scripts.js`), section 6.3 (enable **Static Website Hosting**), section 6.4 (configure **Bucket Policy**), section 6.5 (configure the `student-backup-20250706` bucket), section 5 (build the web interface), section 4.1 (create the `student` API), section 4.2 (create the `StudentApiKey`), section 4.3 (create the `StudentUsagePlan`), section 4.4 (create the **GET /students** method), section 4.5 (create the **POST /students** method), section 4.6 (create the `/backup` resource and **POST /backup** method), section 4.7 (enable CORS), section 4.8 (deploy the API to the `prod` stage), section 4.9 (link the `StudentApiKey` to `StudentUsagePlan`). Ensure your AWS account has `cloudfront:UpdateDistribution`, `s3:GetObject`, and the AWS region is `us-east-1` for related services.
{{% /notice %}}

---

## Detailed Actions

1. **Access the AWS Management Console**  
   - Log in to the **[AWS Management Console](https://console.aws.amazon.com)** with your AWS account.  
   - In the search bar, type **CloudFront** and select the **Amazon CloudFront** service.  
   - Check the AWS region: CloudFront is a global service, but ensure the S3 Bucket `student-management-website-2025`, `student` API, Lambda, DynamoDB, and SES are in `us-east-1`.  
     ![AWS Console Interface with CloudFront Search Bar](/images/7-deploying-cloudfront/7.2-configuring-default-root-object/configuring-default-root-object-01.png)  
     *Figure 1: AWS Console Interface with the CloudFront search bar.*

2. **Select the CloudFront Distribution**  
   - In **CloudFront > Distributions**, find and select the distribution named `StudentWebsiteDistribution` (created in section 7.1).  
     - **Identification**: The distribution ID starts with `E...` and the Domain name is of the format `d12345678.cloudfront.net`.  
   - Click the ID or distribution name to enter the distribution details interface.  
   - Check the status: Ensure the distribution is in the **Enabled** state. If it is still **In Progress**, wait 5–15 minutes for the deployment to complete.  
     ![Select CloudFront Distribution](/images/7-deploying-cloudfront/7.2-configuring-default-root-object/configuring-default-root-object-02.png)  
     *Figure 2: Select CloudFront Distribution.*

3. **Edit Default Root Object**  
   - In the details interface of `StudentWebsiteDistribution`, select the **General** tab.  
   - Find the **Settings** section and click the **Edit** button next to **Default root object** (usually shows the current value if set).  
     ![Find and Click Edit in the Settings Section](/images/7-deploying-cloudfront/7.2-configuring-default-root-object/configuring-default-root-object-03.png)  
     *Figure 3: Find and Click Edit in the Settings Section.*  
   - In the **Default root object** field, enter `index.html`.  
     - **Reason**: `index.html` is the main file containing the web interface (input form, student table, save/view/backup functional buttons) uploaded to the S3 Bucket `student-management-website-2025` (section 6.2). When users access the CloudFront domain, CloudFront will request `index.html` from S3 through OAI (section 7.1).  
   - Review before saving:  
     - Ensure `index.html` has been uploaded to the root directory of the S3 Bucket `student-management-website-2025` (section 6.2).  
     - Verify **Static Website Hosting** is enabled with `index.html` as the **Index document** (section 6.3).  
     - Check the **Bucket Policy** (section 7.1) allows OAI access:  
       ```json
       {
           "Version": "2012-10-17",
           "Statement": [
               {
                   "Sid": "AllowCloudFrontOAI",
                   "Effect": "Allow",
                   "Principal": {
                       "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity EXXXXXX"
                   },
                   "Action": "s3:GetObject",
                   "Resource": "arn:aws:s3:::student-management-website-2025/*"
               }
           ]
       }
       ```

4. **Save Changes**  
   - Click **Save changes** to apply the configuration.  
     ![Click Save Changes to Save Configuration](/images/7-deploying-cloudfront/7.2-configuring-default-root-object/configuring-default-root-object-04.png)  
     *Figure 4: Click Save Changes to Save Configuration.*  
   - Expected result: CloudFront will start updating the configuration (takes 5–10 minutes). Once completed, the distribution status will return to **Enabled**, and AWS will display the message _"Successfully updated distribution settings"_.  
     ![Update Success Message](/images/7-deploying-cloudfront/7.2-configuring-default-root-object/configuring-default-root-object-05.png)  
     *Figure 5: Update Success Message.*  
   - **Error Handling**:  
     - **"AccessDenied"**: Check if the IAM role has `cloudfront:UpdateDistribution` permissions:  
       ```json
       {
           "Version": "2012-10-17",
           "Statement": [
               {
                   "Effect": "Allow",
                   "Action": "cloudfront:UpdateDistribution",
                   "Resource": "arn:aws:cloudfront::<AWS_ACCOUNT_ID>:distribution/<DISTRIBUTION_ID>"
               }
           ]
       }
       ```  
       - Replace `<AWS_ACCOUNT_ID>` and `<DISTRIBUTION_ID>` with actual values (found in CloudFront > Distributions).  
     - **Update not applied**:  
       - Check the distribution status and wait for it to return to **Enabled**.  
       - Verify that the **Default root object** field shows `index.html` in the **General** tab.

5. **Test Default Root Object**  
   - In **CloudFront > Distributions**, copy the **Distribution domain name** (e.g., `https://d12345678.cloudfront.net`).  
   - Open your browser and access this URL.  
   - Expected result:  
     - The web interface should display with the input form, student table, and functional buttons (Save, View, Backup) using Tailwind CSS and Poppins font.  
     - The `styles.css` and `scripts.js` files should load correctly over HTTPS, and the interface should display as expected.  
     - API requests (**GET /students**, **POST /students**, **POST /backup**) should work if CORS is correctly configured (section 4.7).  
     ![Web Interface via CloudFront](/images/7-deploying-cloudfront/7.2-configuring-default-root-object/configuring-default-root-object-06.png)  
     *Figure 6: Web Interface via CloudFront.*  
   - **Error Handling**:  
     - **403 Forbidden**:  
       - Check the **Bucket Policy** for the correct OAI ARN (`arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity EXXXXXX`).  
       - Verify `index.html`, `styles.css`, `scripts.js` are uploaded to S3 (section 6.2).  
       - Ensure the old public policy (`Principal: "*"`) has been removed (section 6.4).  
     - **404 Not Found**:  
       - Check that **Default root object** is set to `index.html` in CloudFront > Distributions > General.  
       - Verify that **Static Website Hosting** is enabled with `index.html` as the **Index document** (section 6.3).  
     - **Incorrect Interface**:  
       - Open **Developer Tools > Console** to check for errors loading `styles.css` or `scripts.js`.  
       - Check the paths in `index.html` (e.g., `<link href="styles.css">`, `<script src="scripts.js">`).  
     - **CORS**: Check the CORS configuration in API Gateway (section 4.7) with `Access-Control-Allow-Origin: https://d12345678.cloudfront.net`.  
     - **API Errors**: Check `StudentApiKey`, `StudentUsagePlan` (section 4.9), and CloudWatch logs for Lambda.

---

## Important Notes

| Factor | Details |
|--------|---------|
| **Security** | Ensure the **Bucket Policy** allows only OAI access to S3 (section 7.1). Avoid embedding `StudentApiKey` in `scripts.js`. Use CloudFront Functions to add the `x-api-key` header: <br> ```javascript <br> function handler(event) { <br>     var request = event.request; <br>     request.headers['x-api-key'] = { value: 'xxxxxxxxxxxxxxxxxxxx' }; <br>     return request; <br> } <br> ``` |
| **Optimization** | Enable **CloudFront Standard Logs** to track access: In **CloudFront > Distribution > General > Logging**, select **On**, and specify a log bucket (e.g., `student-web-logs-20250706`). Use AWS CLI to check the configuration: <br> ```bash <br> aws cloudfront get-distribution --id <DISTRIBUTION_ID> <br> ``` |
| **System Integration** | Update CORS in API Gateway (section 4.7) with `Access-Control-Allow-Origin: https://d12345678.cloudfront.net`. Ensure **POST /students**, **GET /students**, **POST /backup** work with **Invoke URL** and `StudentApiKey`. |
| **Integration Testing** | Access the CloudFront URL (https://d12345678.cloudfront.net) and check: <br> - **POST /students**: Save records, send SES email. <br> - **GET /students**: Display table. <br> - **POST /backup**: Create file in `student-backup-20250706`, send email. <br> Use **Developer Tools > Network** to check API requests. |
| **Error Handling** | **403 Forbidden**: Check OAI ARN, **Bucket Policy**, `s3:GetObject` permission. **404 Not Found**: Verify `index.html` is the **Default root object**, file exists in S3. **Incorrect Interface**: Check **Developer Tools > Console**, paths in `index.html`. **CORS**: Check `Access-Control-Allow-Origin` header in Lambda (section 3) and API Gateway (section 4.7). **429**: Check rate/burst/quota limits in `StudentUsagePlan` (section 4.3). |

> **Best Practice Tip**: Test the CloudFront URL immediately after setting the **Default root object**. Create invalidation (section 7.3) if updating files in S3. Use AWS CLI to check the configuration: `aws cloudfront get-distribution --id <DISTRIBUTION_ID>`.

---

## Conclusion

The **Default Root Object** has been configured as `index.html` for the CloudFront Distribution `StudentWebsiteDistribution`, ensuring the web interface displays correctly when accessing the CloudFront domain. The system is now ready to integrate with the `student` API.

> **Next step**: Proceed to [Create Invalidation to Refresh Cache](/7-deploying-cloudfront/7.3-creating-cloudfront-invalidation/) to continue!
