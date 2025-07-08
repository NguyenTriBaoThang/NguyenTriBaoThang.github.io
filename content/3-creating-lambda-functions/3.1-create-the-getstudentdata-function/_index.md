---
title: "Configure Lambda Function getStudentData"
date: 2023-10-25
weight: 1
chapter: false
pre: "<b>3.1. </b>"
---

> **Objective**: Create and configure the Lambda function `getStudentData` to retrieve all student data from the DynamoDB `studentData` table, including fields Student ID (`studentid`), Full Name (`name`), Class (`class`), Date of Birth (`birthdate`), and Email (`email`). This function uses the Scan operation to fetch the data and returns the results in JSON format, supporting integration with the web interface via API Gateway.

The function will use **Python 3.13**, architecture `x86_64`, assigned the IAM role `LambdaGetStudentRole` (created in section 2.1), and integrated with DynamoDB.

---

## Initial Requirements

{{% notice info %}}
You need to complete the preparation steps in section 2 (IAM Role `LambdaGetStudentRole`, DynamoDB table `studentData`) before creating the function. Ensure your AWS account is ready and the AWS region is `us-east-1`.
{{% /notice %}}

---

## Overview of the getStudentData Function

The `getStudentData` function performs the following tasks:  
- Connects to the DynamoDB `studentData` table in the AWS region (default is `us-east-1`).  
- Performs a **Scan** operation to retrieve all student data, handling pagination if the table is large.  
- Returns the data in JSON format with a CORS header (`Access-Control-Allow-Origin: '*'`) so that the web interface (running on CloudFront) can access it via API Gateway.  
- Logs to CloudWatch for monitoring and debugging (supported by the `AWSLambdaBasicExecutionRole` policy).

---

## Detailed Steps

1. **Access AWS Management Console**  
   - Open your browser and log in to the **[AWS Management Console](https://console.aws.amazon.com)** with your AWS account.  
   - In the search bar at the top, type **Lambda** and select **AWS Lambda** to enter the management interface.  
   - Ensure the AWS region is `us-east-1` (matching the `studentData` table), check in the top-right corner of the AWS Console.  

     ![AWS Console with Lambda Search Bar](/images/4-lambda-functions/1-getstudentdata/lambda-functions-getstudentdata-01.png)
     *Figure 1: AWS Console interface with the Lambda search bar.*

2. **Navigate to Functions Section**  
   - In the AWS Lambda interface, look at the left-hand navigation menu.  
   - Select **Functions** to see the list of existing Lambda functions. If none exist, the list will be empty.  

     ![Navigation Menu with Functions Option](/images/4-lambda-functions/1-getstudentdata/lambda-functions-getstudentdata-02.png)
     *Figure 2: Navigation menu with the Functions option.*

3. **Start the Create Function Process**  
   - In the **Functions** interface, click the **Create function** button in the top-right corner to start configuring a new function.  

     ![Create Function Button in Functions Interface](/images/4-lambda-functions/1-getstudentdata/lambda-functions-getstudentdata-03.png)
     *Figure 3: Create function button in the Functions interface.*

4. **Configure Basic Function Information**  
   - In the **Function type** section, select **Author from scratch**.  
   - In the **Function name** field, enter `getStudentData`.  
   - In the **Runtime** section, select **Python 3.13**. If Python 3.13 is unavailable, select the latest version (e.g., Python 3.12 or 3.11).  
   - In the **Architecture** section, select `x86_64`.  

     ![Basic Function Information Configuration](/images/4-lambda-functions/1-getstudentdata/lambda-functions-getstudentdata-04.png)
     *Figure 4: Basic function configuration interface.*  

   - In the **Permissions** section, choose **Use an existing role**, and select `LambdaGetStudentRole` (created in section 2.1, including `AWSLambdaBasicExecutionRole`, `AmazonDynamoDBReadOnlyAccess`, `AmazonS3FullAccess`, `CloudFrontFullAccess`).  
   - Note: `AmazonS3FullAccess` and `CloudFrontFullAccess` are not used in the current code but are retained from previous requirements.  
   - Keep the other settings as defaults and click **Create function**.  

     ![Select LambdaGetStudentRole and Create Function](/images/4-lambda-functions/1-getstudentdata/lambda-functions-getstudentdata-05.png)
     *Figure 5: Select `LambdaGetStudentRole` and click Create function.*

5. **Check the Function Creation Status**  
   - After clicking **Create function**, you will be redirected to the `getStudentData` function details page.  
   - The interface will display a message like: _"Successfully created the function getStudentData. You can now change its code and configuration. To invoke your function with a test event, choose Test."_  
   - If you don't see this message or encounter an error, check that `LambdaGetStudentRole` exists and that your AWS account has the `lambda:CreateFunction` permission.  

     ![Function Details Page After Creation](/images/4-lambda-functions/1-getstudentdata/lambda-functions-getstudentdata-06.png)
     *Figure 6: Function details page after creating `getStudentData`.*

6. **Configure Source Code**  
   - In the **Code** tab, scroll down to the **Code source** section.  
   - In the `lambda_function.py` file, delete the default code and paste the following:

```python
import json
import boto3

def lambda_handler(event, context):
    # Connect to DynamoDB in the us-east-1 region
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    table = dynamodb.Table('studentData')

    # Retrieve all data from the studentData table
    response = table.scan()
    data = response['Items']

    # Continue scanning if there is more data (pagination)
    while 'LastEvaluatedKey' in response:
        response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
        data.extend(response['Items'])

    # Return the data in JSON format
    return {
        'statusCode': 200,
        'body': json.dumps(data),
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        }
    }
