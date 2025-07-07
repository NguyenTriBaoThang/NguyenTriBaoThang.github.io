---
title: "Configure Lambda Function insertStudentData"
date: 2023-10-25
weight: 2
chapter: false
pre: "<b>3.2 </b>"
---

> **Objective**: Create and configure the Lambda function `insertStudentData` to receive student information from the web interface, store it in the DynamoDB `studentData` table, and send a confirmation email via SES. This function processes the data for fields Student ID (`studentid`), Full Name (`name`), Class (`class`), Date of Birth (`birthdate`), and Email (`email`), while checking for validity and duplicates before saving. The function uses **Python 3.13**, architecture `x86_64`, and assigns the IAM role `LambdaInsertStudentRole` (corrected from `LambdaGetStudentRole` in the requirements). The function will return a JSON response for integration with the web interface via API Gateway.

---

## Overview of the insertStudentData Function

The `insertStudentData` function performs the following tasks:  
- Receives data from `event['body']` (sent from the web interface via API Gateway).  
- Validates the input data (ensuring all required fields are provided).  
- Checks for duplicate `studentid` using the `GetItem` operation to avoid storing duplicate data.  
- Saves the data to the `studentData` table using the `PutItem` operation.  
- Sends a confirmation email via SES with detailed content (student ID, full name, class, date of birth).  
- Logs details to CloudWatch for monitoring and debugging.  
- Returns a JSON response with the CORS header (`Access-Control-Allow-Origin: '*'`) to support the web interface.

---

## Initial Requirements

{{% notice info %}}
You need to complete the preparation steps in section 2 (IAM Role `LambdaInsertStudentRole`, DynamoDB `studentData` table, SES email verification) before creating the function. Ensure your AWS account is ready and the AWS region is `us-east-1`.
{{% /notice %}}

---

## Detailed Steps

1. **Access AWS Management Console**  
   - Open your browser and log in to the **[AWS Management Console](https://console.aws.amazon.com)** with your AWS account.  
   - In the search bar at the top, type **Lambda** and select **AWS Lambda** to enter the management interface.  
   - Ensure you are working in the primary AWS region (e.g., `us-east-1`), check the region in the top-right corner of the AWS Console. This region should match the `studentData` DynamoDB table and SES.  

     ![AWS Console with Lambda Search Bar](/images/4-lambda-functions/2-insertstudentdata/lambda-functions-insertstudentdata-01.png)
     *Figure 1: AWS Console interface with the Lambda search bar.*

2. **Navigate to the Functions Section**  
   - In the AWS Lambda interface, look at the left-hand navigation menu.  
   - Select **Functions** to see the list of existing Lambda functions. If no functions have been created, the list will be empty.  

     ![Navigation Menu with Functions Option](/images/4-lambda-functions/2-insertstudentdata/lambda-functions-insertstudentdata-02.png)  
     *Figure 2: Navigation menu with the Functions option.*

3. **Start the Create Function Process**  
   - In the **Functions** interface, click the **Create function** button in the top-right corner to start configuring a new function.  

     ![Create Function Button in Functions Interface](/images/4-lambda-functions/2-insertstudentdata/lambda-functions-insertstudentdata-03.png)
     *Figure 3: Create function button in the Functions interface.*

4. **Configure Basic Function Information**  
   - In the **Function type** section, select **Author from scratch** to write your own code for the function.  
   - In the **Function name** field, enter `insertStudentData`. This name will be used when integrating with API Gateway.  
   - In the **Runtime** section, select **Python 3.13** (the latest required Python version). If Python 3.13 is not available, select the latest supported version (e.g., Python 3.12 or 3.11).  
   - In the **Architecture** section, select `x86_64` to ensure compatibility with the standard architecture.  

    ![Basic Function Information Configuration](/images/4-lambda-functions/2-insertstudentdata/lambda-functions-insertstudentdata-04.png)  
     *Figure 4: Basic function configuration interface.*  

   - In the **Permissions** section, select **Use an existing role**.  
     - In the role list, select `LambdaInsertStudentRole` (created in section 2.2).  
     - **Important note**: The initial requirement specified `LambdaGetStudentRole`, but this role is not suitable as it lacks the `dynamodb:PutItem` and `ses:SendEmail` permissions. The `LambdaInsertStudentRole` includes `AWSLambdaBasicExecutionRole`, `AmazonDynamoDBReadOnlyAccess`, `AmazonSESFullAccess`, `AmazonS3FullAccess`, and `CloudFrontFullAccess`, but `AmazonDynamoDBReadOnlyAccess` does not support `PutItem`. You need to replace it with `AmazonDynamoDBFullAccess` or a custom policy (see Notes).  
   - Keep other settings at their default values and click **Create function** to create the function.  

     ![Select LambdaInsertStudentRole and Create Function](/images/4-lambda-functions/2-insertstudentdata/lambda-functions-insertstudentdata-05.png)  
     *Figure 5: Select `LambdaInsertStudentRole` and click Create function.*

5. **Check Function Creation Status**  
   - After clicking **Create function**, you will be redirected to the `insertStudentData` function details page.  
   - The interface will display a message like: _"Successfully created the function insertStudentData. You can now change its code and configuration. To invoke your function with a test event, choose Test."_  
   - If you do not see this message or encounter an error, check that the `LambdaInsertStudentRole` exists and that your AWS account has the `lambda:CreateFunction` permission.  

     ![Function Details Page After Creation](/images/4-lambda-functions/2-insertstudentdata/lambda-functions-insertstudentdata-06.png)  
     *Figure 6: Function details page after creating `insertStudentData`.*

6. **Configure Source Code**  
   - In the function details page for `insertStudentData`, go to the **Code** tab, scroll down to the **Code source** section.  
   - In the `lambda_function.py` file, delete the default code and paste the following:

```python
import json
import boto3
import logging

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize DynamoDB and SES clients
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('studentData')
ses = boto3.client('ses', region_name='us-east-1')

def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))

    # Process request body
    try:
        if isinstance(event.get('body'), str):
            body = json.loads(event['body'])
        elif isinstance(event.get('body'), dict):
            body = event['body']
        else:
            body = {}
    except Exception as e:
        logger.error("Error parsing JSON: %s", str(e))
        return _response(400, "Invalid data sent.")

    # Extract fields
    student_id = body.get('studentid')
    name = body.get('name')
    student_class = body.get('class')
    birthdate = body.get('birthdate')
    email = body.get('email')

    # Validate input data
    if not all([student_id, name, student_class, birthdate, email]):
        logger.error("Missing fields: studentid=%s, name=%s, class=%s, birthdate=%s, email=%s",
                     student_id, name, student_class, birthdate, email)
        return _response(400, "Missing required student information.")

    # Check for duplicate student ID
    try:
        existing = table.get_item(Key={'studentid': student_id})
        if 'Item' in existing:
            logger.error("Student ID %s already exists", student_id)
            return _response(409, f"Student ID '{student_id}' already exists.")
    except Exception as e:
        logger.error("Error checking student ID: %s", str(e))
        return _response(500, "Error checking data.")

    # Save data to DynamoDB
    try:
        table.put_item(
            Item={
                'studentid': student_id,
                'name': name,
                'class': student_class,
                'birthdate': birthdate,
                'email': email
            }
        )
        logger.info("Successfully saved data for studentid: %s", student_id)
    except Exception as e:
        logger.error("Error saving to DynamoDB: %s", str(e))
        return _response(500, "Error saving data to the system.")

    # Send confirmation email
    email_error = None
    try:
        ses.send_email(
            Source='baothangvip@gmail.com',
            Destination={'ToAddresses': [email]},
            Message={
                'Subject': {'Data': 'Student Data Saved'},
                'Body': {
                    'Text': {
                        'Data': (
                            f'📢 STUDENT MANAGEMENT SYSTEM NOTIFICATION\n\n'
                            f'Hello {name},\n\n'
                            f'✅ Your student information has been successfully saved to the system.\n\n'
                            f'🔹 Student ID: {student_id}\n'
                            f'🔹 Full Name: {name}\n'
                            f'🔹 Class: {student_class}\n'
                            f'🔹 Date of Birth: {birthdate}\n\n'
                            f'📬 Please keep this email for reference.\n\n'
                            f'Best regards,\n'
                            f'📘 Student Management System\n'
                            f'📧 Email: hutech@system.edu.vn'
                        )
                    }
                }
            }
        )
        logger.info("Successfully sent email to: %s", email)
    except Exception as e:
        email_error = str(e)
        logger.error("Error sending email to %s: %s", email, email_error)

    # Return result
    if email_error:
        return _response(200, f"Student data saved, but email to {email} failed: {email_error}")
    return _response(200, "Student data saved and confirmation email sent!")

# Helper function to return response
def _response(status_code, message):
    return {
        'statusCode': status_code,
        'body': json.dumps({'message': message}),
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        }
    }
