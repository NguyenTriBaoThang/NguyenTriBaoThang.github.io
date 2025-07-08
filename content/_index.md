---
title: "Serverless Website"
date: 2023-10-25
weight: 1
chapter: false
---

# Deploying a Serverless Student Information Management Website with AWS

> **Welcome to the hands-on workshop!**  
> Build a **serverless** web application using modern AWS services to manage student information in a **secure**, **efficient**, and **cost-effective** way.

## Overview

This workshop will guide you step by step in building a **serverless website** using powerful AWS services to manage student information. The application supports:  
- **Input and output student data** with fields: **Student ID**, **Full Name**, **Class**, **Birth Date**, and **Email**.  
- A **user-friendly interface** designed with **Tailwind CSS** for a smooth user experience.  
- **Security**: Uses **API Key** via **API Gateway** to authenticate requests.  
- **Notifications**: Sends confirmation emails and backups via **AWS SES**.  
- **Automated Backup**: Backs up data from **DynamoDB** to **S3** on a schedule.  

By using serverless services like **S3**, **DynamoDB**, **Lambda**, **API Gateway**, **CloudFront**, and **SES**, you will learn how to deploy an application that:  
- **Requires no server management**.  
- **Saves costs** with a pay-per-use model.  
- **Scales automatically** based on traffic.  
- **Optimizes global performance** with low latency.

**System Architecture Overview**:

![System Architecture Overview](images/system-architecture-overview.jpg)  
*Figure 1: Overview diagram of the serverless application architecture with AWS services.*

---

## Workshop Content

The workshop includes detailed steps to build a complete serverless application. Below is a list of the content:

| **Step** | **Content** | **Description** |
|----------|-------------|-----------------|
| 1 | [Introduction](1-introduction/) | Overview of the workshop, benefits of serverless architecture, and learning objectives. |
| 2 | [Preparation Steps](2-preparation-steps/)  | Guide to set up your AWS account, install required tools, and prepare the environment. |
| 3 | [Configuring Lambda Functions](3-creating-lambda-functions/) | Create Lambda functions to handle logic, such as retrieving and storing student data. |
| 4 | [Create a RESTful API](1-Introduction/) | Configure API Gateway to create a secure API, integrate with Lambda. |
| 5 | [Build the Website Interface](1-Introduction/) | Design the web interface with Tailwind CSS to input/output student data. |
| 6 | [Configure the S3 Bucket](1-Introduction/)| Create and configure an S3 bucket to store static content and backup data. |
| 7 | [Deploy CloudFront](1-Introduction/) | Use CloudFront to distribute content globally with low latency. |
| 8 | [Set up System Backup](1-Introduction/) | Automate the backup of data from DynamoDB to S3 using EventBridge. |
| 9 | [Verify the Results](1-Introduction/) | Verify the application’s functionality through test scenarios. |
| 10 | [View Logs with CloudWatch](1-Introduction/) | Monitor and analyze system logs to optimize performance. |
| 11 | [Demo Video](1-Introduction/)| Watch a demo video illustrating how the application works. |
| 12 | [Cleanup Resources](1-Introduction/) | Guide on how to delete AWS resources to avoid unnecessary costs. |

> **Note**: Each step is designed to let you practice each part of the application, from configuring the database to deploying the interface and monitoring the system. Follow the steps in order for the best results.

---

## Starting the Journey

By completing this workshop, you will:  
- Have a **complete serverless application**, ready for real-world use.  
- Gain **practical skills** to integrate AWS services like Lambda, DynamoDB, API Gateway, S3, CloudFront, SES, and CloudWatch.  
- Be confident in developing other serverless applications in the future.

> **Ready to get started?**  
> Go to [Introduction](1-introduction/) to explore more about the application and the benefits of serverless architecture!
