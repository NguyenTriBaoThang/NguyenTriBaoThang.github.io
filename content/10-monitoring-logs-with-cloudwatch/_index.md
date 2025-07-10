---
title: "Monitoring Activity Logs with CloudWatch"
date: 2025-07-09
weight: 10
chapter: false
pre: "<b>10. </b>"
---

> **Objective**: Use Amazon CloudWatch to view and manage activity logs of Lambda functions (`DynamoDBBackup`, `getStudentData`, `insertStudentData`) in the serverless system. Focus on checking logs of the `insertStudentData` function (integrated with the **POST /students** endpoint, section 4.5) to monitor student data saving to DynamoDB `studentData` and email sending via Amazon SES. Logs help verify functionality, detect errors, and optimize performance.

---

## Overview of CloudWatch Logs

- **Role of CloudWatch Logs**:  
  - Collect and store logs from Lambda functions (`DynamoDBBackup`, `getStudentData`, `insertStudentData`) in Log Groups for monitoring, debugging, and performance analysis.  
  - The `insertStudentData` function (section 3.2) handles **POST /students**, saves records (studentid, name, class, birthdate, email) to DynamoDB `studentData`, and sends confirmation emails via SES.  
  - Logs record:  
    - Successful API requests (statusCode: 200).  
    - Errors (e.g., AccessDenied, ValidationException).  
    - Performance (Duration, Memory Used).  
- **System Integration**:  
  - The web interface (CloudFront `StudentWebsiteDistribution`, sections 7.1–7.3) from S3 `student-management-website-2025` (sections 6.1–6.4) calls the `student` API (stage `prod`, section 4.8) with **Invoke URL** (e.g., `https://abc123.execute-api.us-east-1.amazonaws.com/prod`) and `StudentApiKey` (section 4.2).  
  - Functions:  
    - **POST /students**: Save record, send SES email.  
    - **GET /students**: Display data from `getStudentData`.  
    - **POST /backup**: Save JSON file to `student-backup-20250706` (section 6.5) via `DynamoDBBackup` (section 8.1).  
  - CORS configured (section 4.7) supports requests from CloudFront (e.g., `https://d12345678.cloudfront.net`).  
  - Role `DynamoDBBackupRoleStudent` (section 6.5) grants DynamoDB, S3, SES permissions.  
  - EventBridge Rule `DailyDynamoDBBackup` (section 8.2) runs backup at 07:00 AM +07.

---

## Detailed Actions

1. **Access AWS Management Console and CloudWatch**  
   - Log in to **[AWS Management Console](https://console.aws.amazon.com)**.  
   - Search for **CloudWatch**, select **Amazon CloudWatch**.  
   - Verify AWS region: `us-east-1` to synchronize with DynamoDB `studentData`, S3 (`student-management-website-2025`, `student-backup-20250706`), Lambda, API Gateway, SES, CloudFront.  
     ![AWS Console interface with CloudWatch search bar.](/images/10-monitoring-logs-with-cloudwatch/monitoring-logs-with-cloudwatch-01.png)
     *Figure 1: AWS Console interface with CloudWatch search bar.*

2. **Select Log Groups**  
   - In **CloudWatch**, select **Log groups** from the left menu.  
   - Check: Verify the following Log Groups exist:  
     - `/aws/lambda/DynamoDBBackup` (for **POST /backup**, section 8.1).  
     - `/aws/lambda/getStudentData` (for **GET /students**, section 4.4).  
     - `/aws/lambda/insertStudentData` (for **POST /students**, section 4.5).  
     ![Log Groups list.](/images/10-monitoring-logs-with-cloudwatch/monitoring-logs-with-cloudwatch-02.png)
     *Figure 2: Log Groups list.*

3. **Select the Log Group for Lambda insertStudentData**  
   - In **Log groups**, click on `/aws/lambda/insertStudentData`.  
   - **Identification**: Contains logs of the `insertStudentData` function, recording **POST /students** activity (saving records to `studentData`, sending SES email).  
   - Trigger the function (if no logs): Send an API request:  
     ```bash
     curl -X POST https://abc123.execute-api.us-east-1.amazonaws.com/prod/students \
         -H "x-api-key: xxxxxxxxxxxxxxxxxxxx" \
         -H "Content-Type: application/json" \
         -d '{"studentid":"SV005","name":"Pham Thi E","class":"CNTT05","birthdate":"2001-05-05","email":"student5@example.com"}'
     ```
     ![insertStudentData Log Group interface.](/images/10-monitoring-logs-with-cloudwatch/monitoring-logs-with-cloudwatch-03.png)
     *Figure 3: insertStudentData Log Group interface.*

4. **View Log Streams**  
   - In `/aws/lambda/insertStudentData`, view the list of **Log Streams** (e.g., `2025/07/09/[$LATEST]abc123`).  
   - Click the most recent **Log Stream** (based on **Last Event Time**) to view details.  
   - Check: Log Streams are created from:  
     - **POST /students** requests via CloudFront (`https://d12345678.cloudfront.net`).  
     - Manual test in Lambda Console (section 3.2).  
     ![Log Streams list.](/images/10-monitoring-logs-with-cloudwatch/monitoring-logs-with-cloudwatch-04.png)
     *Figure 4: Log Streams list.*

5. **Analyze Information in Log Stream**  
   - In the **Log Stream**, check:  
     - **START RequestId**: Start of execution.  
     - **END RequestId**: End of execution.  
     - **REPORT RequestId**: Performance (Duration, Billed Duration, Memory Used, Max Memory Used).  
     - **Custom**: Logs from `console.log` (e.g., _Successfully saved to DynamoDB_).  
     - **Errors**: AccessDenied, ValidationException, SES error.  
   - **Analysis**:  
     - **Success**: Log shows data saved to `studentData`, email sent via SES. Verify record (e.g., `SV005`) in DynamoDB and email at `student5@example.com`.  
     - **Performance**: Duration ~456 ms, Memory Used ~72 MB (within 128 MB limit, section 8.1).  
     - **Potential errors**:  
       - **AccessDenied**: Missing `dynamodb:PutItem`, `ses:SendEmail` permissions in `DynamoDBBackupRoleStudent`.  
       - **ValidationException**: Invalid input data (e.g., missing `studentid`).  
       - **SES error**: Email `no-reply@studentapp.com` or `student5@example.com` not verified in SES.  
     ![Log Stream details.](/images/10-monitoring-logs-with-cloudwatch/monitoring-logs-with-cloudwatch-05.png)
     *Figure 5: Log Stream details.*

6. **Use CloudWatch Logs Insights**  
   - In **CloudWatch > Logs > Logs Insights**, select `/aws/lambda/insertStudentData`.  
   - Successful query:  
     ```log
     fields @timestamp, @message
     | filter @message like /Successfully saved to DynamoDB/
     | sort @timestamp desc
     | limit 20
     ```
   - Error query:  
     ```log
     fields @timestamp, @message
     | filter @message like /ERROR/
     | sort @timestamp desc
     | limit 20
     ```
   - Click **Run query**.  
   - **Results**: Displays logs with time, message, error details (if any).  
   - **Troubleshooting**:  
     - **AccessDenied**: Check `dynamodb:PutItem`, `ses:SendEmail` permissions in `DynamoDBBackupRoleStudent`:  
       ```json
       {
           "Version": "2012-10-17",
           "Statement": [
               {
                   "Effect": "Allow",
                   "Action": [
                       "dynamodb:PutItem",
                       "ses:SendEmail"
                   ],
                   "Resource": [
                       "arn:aws:dynamodb:us-east-1:<AWS_ACCOUNT_ID>:table/studentData",
                       "arn:aws:ses:us-east-1:<AWS_ACCOUNT_ID>:identity/*"
                   ]
               }
           ]
       }
       ```
       Replace `<AWS_ACCOUNT_ID>` with your AWS account ID.  
     - **ValidationException**: Check API input data (e.g., `studentid`, `name` not empty).  
     - **SES error**: Verify email in SES (section 3).  
     - **No logs**: Ensure the function is triggered and CloudWatch Logs are enabled (section 8.1).  
     ![CloudWatch Logs Insights.](/images/10-monitoring-logs-with-cloudwatch/monitoring-logs-with-cloudwatch-06.png)
     *Figure 6: CloudWatch Logs Insights.*

---

## Important Notes

| **Factor** | **Details** |
|------------|-------------|
| **Security** | - Ensure the `DynamoDBBackupRoleStudent` role only grants necessary permissions (`dynamodb:PutItem`, `ses:SendEmail`). <br> - Do not embed `StudentApiKey` in `scripts.js`. Use CloudFront Functions: <br> ```javascript <br> function handler(event) { <br> var request = event.request; <br> request.headers['x-api-key'] = { value: 'xxxxxxxxxxxxxxxxxxxx' }; <br> return request; <br> } <br> ``` |
| **Optimization** | - Enable CloudWatch Logs for Lambda (section 8.1). <br> - Use AWS CLI to check logs: <br> ```bash <br> aws logs describe-log-streams --log-group-name /aws/lambda/insertStudentData <br> ``` |
| **Integration** | - Verify CORS in API Gateway (section 4.7): `Access-Control-Allow-Origin: https://d12345678.cloudfront.net`. <br> - Test **POST /students** via CloudFront URL to generate new logs. |
| **Integration Testing** | - Access CloudFront URL (`https://d12345678.cloudfront.net`): <br> - **POST /students**: Save record, send SES email. <br> - **GET /students**: Display table. <br> - **POST /backup**: Create file in `student-backup-20250706`, send email. <br> - Use **Developer Tools > Network** to inspect API requests. |
| **Error Handling** | - **No logs**: Check CloudWatch Logs are enabled in Lambda, trigger the function via API. <br> - **AccessDenied**: Verify `logs:DescribeLogGroups`, `logs:GetLogEvents` permissions. <br> - **ValidationException**: Check input data. <br> - **SES error**: Verify SES email. |

> **Best practice tip**: Trigger **POST /students** via the web interface to generate new logs. Use Logs Insights to quickly filter errors. Set CloudWatch Alarms for Duration or Memory Used if you need performance monitoring.

---

## Conclusion

CloudWatch Logs allow you to monitor the activity of the `insertStudentData` Lambda, verify data is saved to `studentData` and emails are sent via SES. Logs help debug and optimize the serverless system, integrated with the `student` API and web interface via CloudFront.

> **Next step**: Optimize the system or set up CloudWatch Alarms for