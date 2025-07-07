---
title: "Introduction"
date: 2023-10-25
weight: 1
chapter: false
pre: "<b>1. </b>"
---

> **Explore the future of web development!**  
> This workshop will guide you through the journey of building an advanced **serverless** web application, leveraging the power of AWS to manage student information in a **secure**, **efficient**, and **cost-effective** way.

In the context of modern technology, building efficient, flexible, and cost-effective web applications is the primary goal of developers. The workshop **"Deploying a Serverless Website for Managing Student Information with AWS Services"** will guide you step by step in developing a serverless website, utilizing the powerful AWS services to manage student information securely and optimally.

The application supports:
- **Entering and retrieving student data** with fields like: **Student ID**, **Full Name**, **Class**, **Date of Birth**, and **Email**.
- **Intuitive user interface** designed with **Tailwind CSS**, providing a smooth user experience.
- **Serverless architecture**, eliminating the need for server management.
- **Advanced features**: Security, email notifications, and automatic backups to meet real-world needs.

---

## Benefits of Serverless Applications

The serverless architecture of AWS offers outstanding advantages, helping you build a student information management system that is not only efficient but also scalable and maintainable. Here are the key benefits:

### 1. Automatic Scaling
AWS Lambda automatically adjusts resources based on traffic, ensuring smooth application performance even during traffic spikes.

> **Real-world example**: When hundreds of students access the system simultaneously to view or update their information, Lambda automatically allocates resources without requiring your intervention, helping to:
> - Optimize operating costs.
> - Prevent resource waste during periods of low usage.

### 2. Optimal Security
API Gateway uses **API Keys** to authenticate requests, ensuring that only authorized users can access the data. The system integrates **IAM (Identity and Access Management)** with distinct roles such as:
- `LambdaGetStudentRole`
- `LambdaInsertStudentRole`
- `DynamoDBBackupRole`

> **Real-world example**: The Lambda function that fetches data is only allowed to read from DynamoDB, while the backup function only writes to S3, adhering to the **least privilege** principle.  
> **Benefits**:  
> - Protects sensitive data.  
> - Reduces the risk of attacks or data breaches.

### 3. Email Notifications
AWS SES (Simple Email Service) provides automatic notifications:  
1. **Data saving confirmation**: Sends an email containing details like **Student ID**, **Full Name**, **Class**, and **Date of Birth** when data is saved into DynamoDB.  
2. **Data backup**: Sends an email with a **pre-signed URL** (expires after 1 hour) when data is backed up to S3.  

> **Benefits**: Instant system updates, ensuring reliable and professional notifications.

### 4. Cost Savings
The serverless model charges based on actual resource usage:
- **Lambda**: Charges by execution count and runtime.
- **S3**: Charges by storage size.
- **CloudFront**: Charges based on data transfer.

> **Real-world example**: Ideal for applications with variable traffic, significantly reducing operational costs compared to traditional server models.

### 5. High Performance
AWS CloudFront, a **CDN (Content Delivery Network)** service, delivers static content (HTML, JavaScript) from S3 to users worldwide with low latency.

> **How it works**: Stores content at **Edge Locations** close to users.  
> **Real-world example**: Students accessing the site from Vietnam, the US, or Europe will have a smooth, fast experience.  
> **Benefits**: Faster page loading, enhancing user experience.

### 6. Automatic Backups
The system automatically backs up data from DynamoDB to S3 on a schedule set through **EventBridge** (default: **7:00 AM +07** daily).

> **Process**: The Lambda function `BackupDynamoDBAndSendEmail` creates a JSON file with all student data, stores it in an S3 bucket, and sends a **pre-signed URL** (expires after 1 hour).  
> **Real-world example**: Easily recover data after an incident, ensuring data safety.  
> **Benefits**:  
> - Long-term data protection.  
> - Automated backup process, saving time.

---

## Workshop Goals

This workshop will not only help you deploy a **student information management website**, but also provide **practical knowledge** about integrating AWS services into a serverless architecture. You will learn how to:

| **Goal** | **Technology** | **Outcome** |
|----------|----------------|-------------|
| Design a modern web interface | Tailwind CSS | Intuitive, user-friendly interface |
| Create and secure APIs | API Gateway, API Key | Secure, easy-to-integrate, and scalable API |
| Process and store data | Lambda, DynamoDB | Efficient, reliable data management |
| Send email notifications | SES | Instant, professional notifications |
| Distribute content globally | CloudFront | Fast access, low latency from all regions |
| Automate data backup | S3, EventBridge | Safe, easily recoverable data |
| Monitor system activity | CloudWatch | System performance monitoring and optimization |

---

## Start Your Journey!

By completing this workshop, you will gain:
1. A **fully functional serverless application**, ready for real-world use.  
2. **In-depth skills** to develop serverless applications with AWS.  
3. **Confidence** in integrating cloud services into personal or business projects.

> **Ready to join?**  
> Head over to [Preparation Steps](2-preparation-steps/) to explore the detailed setup process!
