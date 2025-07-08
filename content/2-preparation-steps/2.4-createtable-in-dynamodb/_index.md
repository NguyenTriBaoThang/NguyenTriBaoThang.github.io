---
title: "Create Table in DynamoDB"
date: 2023-10-25
weight: 4
chapter: false
pre: "<b>2.4. </b>"
---

> **Objective**: Set up the **studentData** table in DynamoDB to store student information, including **Student ID (studentid)**, **Full Name**, **Class**, **Date of Birth**, and **Email**, using **studentid** (String type) as the primary key to ensure fast and efficient queries in a serverless architecture.

**DynamoDB**, AWS' **NoSQL** database, provides **automatic scaling** and **low latency**, ideal for student information management applications. The `studentData` table will serve as the foundation for integrating with AWS services such as Lambda, API Gateway, and SES.

---

## Detailed Steps

Below are the detailed steps to create and configure the **studentData** table:

### 1. Access the AWS Management Console
- Open your browser and log in to the **[AWS Management Console](https://console.aws.amazon.com)**.
- In the search bar, type **DynamoDB** and select **DynamoDB** to enter the management interface.

  ![DynamoDB - Access Service](/images/2-dynamobd/dynamobd-01.png)
  *Figure 1: AWS Console interface with the DynamoDB search bar.*

### 2. Navigate to the Tables Section
- In the DynamoDB interface, find the **left-hand navigation menu**.
- Select **Tables** to view the list of existing tables. If no tables exist, the list will be empty.

  ![DynamoDB - Tables List](/images/2-dynamobd/dynamobd-02.png)
  *Figure 2: Navigation menu with the Tables option.*

### 3. Start the Table Creation Process
- In the **Tables** interface, click the **Create Table** button in the top-right corner.

  ![DynamoDB - Create Table Button](/images/2-dynamobd/dynamobd-03.png)
  *Figure 3: Create Table button in the Tables interface.*

### 4. Configure the Table Details
- In the **Table Details** section:
  - **Table Name**: Enter `studentData`.  
    > **Note**: The table name must match exactly with the name used in the Lambda functions (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`).
  - **Partition Key**: Enter `studentid`, select **String** as the type.  
    > **Primary Key**: Ensure each student has a unique identifier (e.g., `SV001`, `SV002`).
  - **Sort Key**: Leave blank (not needed, as queries will be based on `studentid`).
- **Settings**: Use default options:
  - Choose **On-Demand** for **Capacity mode** to automatically adjust resources, saving costs and simplifying management.
  - No need to add **Secondary Indexes** or custom **Encryption** (default is sufficient for this application).
- **Verify the information**:
  - Table Name: `studentData`
  - Partition Key: `studentid (String)`

  ![DynamoDB - Table Configuration](/images/2-dynamobd/dynamobd-04.png)  
  *Figure 4: Table configuration interface with Table Name and Partition Key.*

### 5. Create the Table
- Click **Create Table** at the bottom of the page.

  ![DynamoDB - Confirm Create Table](/images/2-dynamobd/dynamobd-05.png)
  *Figure 5: Create Table button to confirm.*

- DynamoDB will create the table in about **20-30 seconds**, depending on the AWS region (e.g., `us-east-1`).

  ![DynamoDB - Table Creation Process](/images/2-dynamobd/dynamobd-06.png)
  *Figure 6: Interface showing table creation status.*

### 6. Check the Table Status
- After clicking **Create Table**, you will return to the **Tables** list.
- Find the `studentData` table. The initial status will be **Creating**.
- Wait for about **30 seconds**, then refresh the page (click **Refresh** or press **F5**).
- Once the status changes to **Active**, the table has been created successfully.
- **Notification**: The interface will show _"The studentData table was created successfully"_.

  ![DynamoDB - Active Status](/images/2-dynamobd/dynamobd-07.png)
  *Figure 7: The studentData table with Active status.*

### 7. Verify the Table Configuration
- Click on the `studentData` table to view details.
- Check:
  - **Table ARN**: For example, `arn:aws:dynamodb:us-east-1:your-account-id:table/studentData`.
  - **Partition Key**: `studentid (String)`.
  - **Capacity Mode**: **On-Demand**.
  - **Sort Key**: None.
- Other attributes (**Full Name**, **Class**, **Date of Birth**, **Email**) are dynamic attributes, no need for pre-declaration.

---

## Important Notes

| **Factor** | **Details** |
|------------|-------------|
| **Table Name** | Must be `studentData` (case-sensitive) to match the Lambda code. Incorrect names will cause query errors. |
| **AWS Region** | Create the table in the same AWS region as other services (e.g., `us-east-1`). Check the region in the top-right corner of the AWS Console. |
| **Creation Time** | If the **Creating** status lasts longer than 30 seconds, check your network connection or refresh the page. If an error occurs, delete the table and try again. |
| **Optimization** | For large data (>500 MB), consider enabling **Point-in-time Recovery (PITR)** in the **Backups** tab for recovery support. Backup via Lambda and S3 is sufficient for this application. |
| **Check Early** | Once the table is in **Active** status, go to the **Items** tab and select **Create Item** to enter a sample record: <br> - `studentid`: `SV001` <br> - `name`: `Nguyễn Văn A` <br> - `class`: `CNTT1` <br> - `birthdate`: `2000-01-01` <br> - `email`: `example@gmail.com` <br> Verify the data displays correctly. |

> **Practical Tip**: Check the table configuration immediately after creation to ensure accuracy before integrating with Lambda.

---

## Conclusion

The `studentData` table is the foundation for storing and managing student information in the serverless application. With the primary key `studentid` and **On-Demand** capacity mode, the table ensures **high performance**, **flexible scaling**, and **low latency**. The table is now ready to integrate with **Lambda**, **API Gateway**, and **SES**.

> **Next Step**: Proceed to [Configure SES](/2-prerequisite/2.5-configure-ses/) to set up the email service!
