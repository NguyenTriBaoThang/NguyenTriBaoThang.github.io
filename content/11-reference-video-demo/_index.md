---
title: "Reference Video Demo"
date: 2025-07-09
weight: 11
chapter: false
pre: "<b>11. </b>"
---

> **Objective**: Provide a demo video illustrating the deployment and testing process of the serverless student management website on AWS, integrating S3, CloudFront, API Gateway, Lambda, DynamoDB, SES, and EventBridge. The video helps visualize how to build the application, from infrastructure setup to testing features like entering student information, viewing the list, sending emails, and automatic data backup.

---

## Video Demo Content

- The video demonstrates the steps to deploy and test the serverless system.
- Reference Demo Link: [Here](https://drive.google.com/file/d/1Tjlm74NRt5Dq5NhBiH9JJ4sQtsFQU0DB/view?usp=drive_link)

---

## Video Duration

- **Suggested**: 35 minutes, covering all main steps.  
- **Segments**:  
  - AWS configuration (10 minutes).  
  - Web interface (10 minutes).  
  - Backend and backup testing (15 minutes).  
  - **Timestamps** for easy navigation (e.g., 00:00–10:00: AWS configuration, 10:01–20:00: Web interface).  

---

## Reference Video Sources

If you don't have a specific video, refer to these sources:  
- **AWS Serverless Workshops**: Tutorials at [aws.amazon.com/serverless-workshops](https://aws.amazon.com/serverless-workshops), including videos on building serverless apps (e.g., "to-do list" with Lambda, API Gateway, DynamoDB, Amplify). [Getting Started Guide](https://aws.amazon.com/getting-started/hands-on/build-web-app-s3-lambda-api-gateway-dynamodb/)
- **VTI Cloud**: Videos on configuring Lambda, S3, API Gateway, DynamoDB at [vticloud.io](https://vticloud.io), demonstrating file handling and backup.  
- **Techmaster Vietnam**: "Learn AWS the Hard Way" course at [techmaster.vn](https://techmaster.vn) with hands-on serverless videos (API Gateway, Lambda, DynamoDB).  

---

## How to Use the Video Demo

1. Watch the video to understand the deployment and testing process.  
2. Compare with your AWS Console configuration (S3, CloudFront, Lambda, etc.).  
3. Repeat the steps on your AWS account.  
4. If you encounter errors, refer to section 9 (Testing Results) and section 10 (CloudWatch Logs).  
5. Customize the source code (`index.html`, `scripts.js`, Lambda functions) as needed.  

> **Practical tip**: Watch the video at 1.5x speed to save time. Take notes on configuration steps and compare with your system. Manually test **POST /backup** before relying on the scheduled backup.

---

## Conclusion

The demo video illustrates the entire process of deploying a serverless student management website, from AWS configuration (S3, CloudFront, API Gateway, Lambda, DynamoDB, SES, EventBridge) to testing features (save, view, backup, email). Use the video to reinforce your understanding and optimize your system.

> **Next step**: Review CloudWatch logs (section 10) for performance analysis and implement