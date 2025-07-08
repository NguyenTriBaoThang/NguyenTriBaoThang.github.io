---
title: "Create IAM Role for Lambda Get"
date: 2023-10-25
weight: 2
chapter: false
pre: "<b>2.1. </b>"
---



> **Objective**: Create the IAM role **LambdaGetStudentRole** for the Lambda function `getStudentData`, granting permissions to **read data** from the DynamoDB table `studentData`, **log data** to CloudWatch, and support potential interactions with S3 and CloudFront.

The function **getStudentData** performs a **Scan** operation to retrieve all student data (**Student ID**, **Full Name**, **Class**, **Date of Birth**, **Email**) from the DynamoDB table `studentData`. This role needs to include:  
- Permissions to **log data** to CloudWatch (`AWSLambdaBasicExecutionRole`).  
- Permissions to **read data** from DynamoDB (`AmazonDynamoDBReadOnlyAccess`).  
- Permissions for **S3** and **CloudFront** (`AmazonS3FullAccess`, `CloudFrontFullAccess`) for potential future features.  

> **Note**: `AmazonS3FullAccess` and `CloudFrontFullAccess` are not currently used in the code, but are retained for future functionalities (e.g., saving files to S3 or managing CloudFront).

---

## Detailed Steps

Below are the detailed steps to create the IAM role **LambdaGetStudentRole**:

### 1. Access the AWS Management Console
- Open your browser and log in to the **[AWS Management Console](https://console.aws.amazon.com)** with your AWS account.
- In the search bar at the top of the page, type **IAM** and select **Identity and Access Management (IAM)**.

  ![IAM - Access Service](/images/1-iam-role/get-student/iam-role-get-student-01.png)
  *Figure 1: AWS Console interface with the IAM search bar.*

### 2. Navigate to the Roles Section
- In the IAM interface, find the **left-hand navigation menu**.
- Select **Roles** to view the list of IAM roles. If no roles exist, the list will be empty.

  ![IAM - Roles List](/images/1-iam-role/get-student/iam-role-get-student-02.png)
  *Figure 2: Navigation menu with the Roles option.*

### 3. Start the Role Creation Process
- In the **Roles** interface, click the **Create Role** button in the top-right corner.

  ![IAM - Create Role Button](/images/1-iam-role/get-student/iam-role-get-student-03.png)
  *Figure 3: Create Role button in the Roles interface.*

### 4. Choose Trusted Entity Type
- In the **Select trusted entity** section, choose **AWS Service** to specify that the role is for an AWS service.
- In the **Use case** section, select **Lambda** from the list of services.
- Click **Next** to move to the permission configuration step.

  ![IAM - Choose Lambda Service](/images/1-iam-role/get-student/iam-role-get-student-04.png)
  *Figure 4: Choosing AWS Service and Lambda in Use case.*

### 5. Grant Permissions to the Role
- In the **Permissions** section, add the following four policies:
  - **AWSLambdaBasicExecutionRole**:
    - Type `AWSLambdaBasicExecutionRole` in the search bar.
    - Select the **AWSLambdaBasicExecutionRole** policy.  
      > **Description**: Allows Lambda functions to log to CloudWatch for monitoring and debugging.

    ![IAM - Add AWSLambdaBasicExecutionRole](/images/1-iam-role/get-student/iam-role-get-student-05.png)
    *Figure 5: Selecting the AWSLambdaBasicExecutionRole policy.*

  - **AmazonDynamoDBReadOnlyAccess**:
    - Type `AmazonDynamoDBReadOnlyAccess` in the search bar.
    - Select the **AmazonDynamoDBReadOnlyAccess** policy.  
      > **Description**: Grants read-only access to DynamoDB, supporting operations like **Scan** or **GetItem**.

    ![IAM - Add AmazonDynamoDBReadOnlyAccess](/images/1-iam-role/get-student/iam-role-get-student-06.png)
    *Figure 6: Selecting the AmazonDynamoDBReadOnlyAccess policy.*

  - **AmazonS3FullAccess**:
    - Type `AmazonS3FullAccess` in the search bar.
    - Select the **AmazonS3FullAccess** policy.  
      > **Description**: Grants read, write, and manage S3 buckets for potential future features (e.g., storing additional files).

    ![IAM - Add AmazonS3FullAccess](/images/1-iam-role/get-student/iam-role-get-student-07.png)
    *Figure 7: Selecting the AmazonS3FullAccess policy.*

  - **CloudFrontFullAccess**:
    - Type `CloudFrontFullAccess` in the search bar.
    - Select the **CloudFrontFullAccess** policy.  
      > **Description**: Grants permission to manage CloudFront distributions for potential future features.

    ![IAM - Add CloudFrontFullAccess](/images/1-iam-role/get-student/iam-role-get-student-08.png)
    *Figure 8: Selecting the CloudFrontFullAccess policy.*

- Verify the list of **Permissions policies** to ensure it includes:  
  - `AWSLambdaBasicExecutionRole`  
  - `AmazonDynamoDBReadOnlyAccess`  
  - `AmazonS3FullAccess`  
  - `CloudFrontFullAccess`  
- Click **Next**.

### 6. Name and Review the Role
- In the **Role details** section:
  - **Role Name**: Enter `LambdaGetStudentRole`.  
    > **Note**: The name must match exactly with the Lambda function configuration for `getStudentData`.
  - **Description** (optional): Enter a description, e.g., _"IAM role for Lambda function getStudentData, granting read access to DynamoDB, CloudWatch logging, and supporting S3/CloudFront."_ 

  ![IAM - Enter Role Name](/images/1-iam-role/get-student/iam-role-get-student-09.png)
  *Figure 9: Enter role name and description.*

- Double-check:
  - **Trusted entity**: AWS Service (Lambda).
  - **Permissions**: `AWSLambdaBasicExecutionRole`, `AmazonDynamoDBReadOnlyAccess`, `AmazonS3FullAccess`, `CloudFrontFullAccess`.
- Click **Create Role**.

  ![IAM - Confirm Create Role](/images/1-iam-role/get-student/iam-role-get-student-10.png)
  *Figure 10: Create Role button to confirm.*

### 7. Check Role Creation Status
- After clicking **Create Role**, you will return to the **Roles** list.
- Find the **LambdaGetStudentRole** role. If successful, you should see the message: _"Role LambdaGetStudentRole created"_.
- Click on **LambdaGetStudentRole** to view details:
  - **ARN**: Record the ARN (e.g., `arn:aws:iam::your-account-id:role/LambdaGetStudentRole`) to use when configuring the Lambda function.
  - **Policies**: Verify the inclusion of `AWSLambdaBasicExecutionRole`, `AmazonDynamoDBReadOnlyAccess`, `AmazonS3FullAccess`, `CloudFrontFullAccess`.
- If the role does not appear, refresh the page or double-check the steps.

  ![IAM - Role Details](/images/1-iam-role/get-student/iam-role-get-student-11.png)
  *Figure 11: Role details for LambdaGetStudentRole with ARN and policies.*

---

## Important Notes

| **Factor** | **Details** |
|------------|-------------|
| **Role Name** | Must be `LambdaGetStudentRole` (case-sensitive) to match the Lambda function. Incorrect names will cause execution errors. |
| **S3 and CloudFront** | `AmazonS3FullAccess` and `CloudFrontFullAccess` are not currently used, but kept for future functionality (e.g., storing files in S3 or managing CloudFront). Delete if unnecessary to comply with **least privilege**. |
| **Security Optimization** | Consider creating a custom policy instead of `AmazonDynamoDBReadOnlyAccess` to restrict access specifically to the `studentData` table. |
| **Check Early** | Record the **ARN** and verify the role in IAM before configuring the Lambda function to ensure proper setup. |
| **Error Handling** | If you encounter an "Access Denied" error, check AWS account permissions (`iam:CreateRole`) or contact your administrator. |

> **Practical Tip**: Always verify the ARN and policies immediately after creating the role to confirm configuration before integrating with Lambda.

---

## Conclusion

The IAM role **LambdaGetStudentRole** ensures that the Lambda function `getStudentData` has permissions to **read data** from DynamoDB, **log data** to CloudWatch, and support potential extensions with S3 and CloudFront. This role is now ready to be integrated into the Lambda function in the next steps.

> **Next Step**: Proceed to [Create IAM Role for Lambda Post](/2-Prerequiste/2.2-create-iam-role-for-lambda-post/) to set up the role for the function that stores student data!
