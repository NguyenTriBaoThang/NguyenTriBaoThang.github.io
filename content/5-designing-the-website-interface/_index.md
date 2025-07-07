---
title: "Write the Website Interface"
date: 2023-10-25
weight: 5
chapter: false
pre: "<b>5. </b>"
---

> **Objective**: Build the web interface for the Student Data Management application using HTML, Tailwind CSS, and JavaScript (with jQuery) to:  
> - Allow users to input and save student information (student ID, full name, class, birthdate, email) via the **POST /students** endpoint.  
> - Display the list of students from the **GET /students** endpoint.  
> - Trigger data backup via the **POST /backup** endpoint.  
> The interface will be deployed on Amazon S3 (static bucket, section 2.4) and distributed through CloudFront (section 6), integrated with the `student` API (stage `prod`, section 4.8) using the Invoke URL and `StudentApiKey` (section 4.2) with CORS security (section 4.7).

---

## Overview of the Web Interface

- **index.html**: Provides the interface structure with an input form, function buttons (Save Student Data, View All Students, Backup Data), and a table displaying the list of students.  
- **styles.css**: Uses Tailwind CSS and customizes with the Poppins font, gradient colors, animations, and responsive design.  
- **scripts.js**: Handles the logic for calling the API (**GET /students**, **POST /students**, **POST /backup**) with jQuery, including input validation, HTML encoding to prevent XSS, and handling API responses/errors.  
- **AWS Integration**:  
  - Replace `API_ENDPOINT` with the Invoke URL (e.g., `https://abc123.execute-api.us-east-1.amazonaws.com/prod`) from section 4.8.  
  - Replace `API_KEY` with the value of `StudentApiKey` from section 4.2, securely stored in AWS Secrets Manager or as an environment variable.  
- **Improvements**:  
  - Enhance security by storing the `API_KEY` in AWS Secrets Manager.  
  - Improve user experience with interface notifications (instead of alerts).  
  - Add stricter input validation.  
  - Optimize responsiveness and animations.

---

## Prerequisites

{{% notice info %}}  
You need to complete the steps in section 2.4 (create the static S3 bucket), section 4.1 (create the `student` API), section 4.2 (create the `StudentApiKey` API Key), section 4.3 (create the `StudentUsagePlan` Usage Plan), section 4.4 (create the **GET /students** method), section 4.5 (create the **POST /students** method), section 4.6 (create the `/backup` resource and **POST /backup** method), section 4.7 (enable CORS), section 4.8 (deploy the API to the `prod` stage), section 4.9 (link `StudentApiKey` to `StudentUsagePlan` and associate with the `student` API on stage `prod`), and section 3 (create the Lambda functions `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, `studentData` DynamoDB table, `student-backup-20250706` S3 bucket, SES email verification). Ensure your AWS account is ready and the AWS region is `us-east-1`. You also need access to S3, CloudFront, and API Gateway.  
{{% /notice %}}

---

## Detailed Actions

1. **Configure the `index.html` File**  
   - The `index.html` file defines the interface with an input form, function buttons, and a table displaying students.  

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Data Management</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="styles.css">
</head>
<body class="min-h-screen flex items-center justify-center p-6">
    <div class="form-container card">
        <h1 class="text-4xl font-bold text-center mb-8">Student Management</h1>
        <div class="space-y-6">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                    <label for="studentid" class="block text-sm mb-1">Student ID</label>
                    <input type="text" name="studentid" id="studentid" class="w-full" placeholder="Enter student ID">
                </div>
                <div>
                    <label for="name" class="block text-sm mb-1">Full Name</label>
                    <input type="text" name="name" id="name" class="w-full" placeholder="Enter full name">
                </div>
                <div>
                    <label for="class" class="block text-sm mb-1">Class</label>
                    <input type="text" name="class" id="class" class="w-full" placeholder="Enter class">
                </div>
                <div>
                    <label for="birthdate" class="block text-sm mb-1">Birthdate</label>
                    <input type="date" name="birthdate" id="birthdate" class="w-full">
                </div>
                <div class="md:col-span-2">
                    <label for="email" class="block text-sm mb-1">Email</label>
                    <input type="text" name="email" id="email" class="w-full" placeholder="Enter email">
                </div>
            </div>
            <button id="savestudent" class="btn-primary w-full">Save Student Data</button>
            <p id="studentSaved" class="text-center text-green-600 font-medium text-lg"></p>
            <button id="getstudents" class="btn-primary btn-secondary w-full">View All Students</button>
            <button id="backupstudents" class="btn-primary w-full bg-green-600 text-white p-3 rounded-xl font-semibold hover:bg-green-700">Backup Data</button>
        </div>
        <div id="showStudents" class="mt-8 overflow-x-auto">
            <table id="studentTable" class="w-full">
                <thead>
                    <tr>
                        <th class="text-sm font-semibold">Student ID</th>
                        <th class="text-sm font-semibold">Full Name</th>
                        <th class="text-sm font-semibold">Class</th>
                        <th class="text-sm font-semibold">Birthdate</th>
                        <th class="text-sm font-semibold">Email</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.0/jquery.min.js"></script>
    <script src="scripts.js"></script>
</body>
</html>
```
   - **Note**: Ensure the file is uploaded to the static S3 bucket (section 2.4) and distributed through CloudFront (section 6).

2. **Configure the `styles.css` File**  
   - The `styles.css` file customizes the interface with Tailwind CSS, the Poppins font, and animations.  

```css
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap');

body {
    background: linear-gradient(135deg, #4c1d95 0%, #ec4899 100%);
    font-family: 'Poppins', sans-serif;
    color: #1f2937;
}

.form-container {
    background: rgba(255, 255, 255, 0.97);
    backdrop-filter: blur(12px);
    border-radius: 2rem;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
    padding: 2.5rem;
    max-width: 48rem;
    margin: 2rem auto;
}

h1 {
    background: linear-gradient(to right, #7c3aed, #db2777);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    font-weight: 700;
    letter-spacing: -0.025em;
}

input {
    background: #f8fafc;
    border: 1px solid #e2e8f0;
    border-radius: 0.75rem;
    padding: 0.75rem 1rem;
    transition: all 0.3s ease;
}

input:focus {
    outline: none;
    border-color: #7c3aed;
    box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.2);
}

.btn-primary {
    background: linear-gradient(90deg, #7c3aed, #db2777);
    border-radius: 0.75rem;
    padding: 0.75rem;
    font-weight: 600;
    color: white;
    transition: all 0.3s ease;
}

.btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
    background: linear-gradient(90deg, #6d28d9, #be185d);
}

.btn-secondary {
    background: linear-gradient(90deg, #6b7280, #4b5563);
}

.btn-secondary:hover {
    background: linear-gradient(90deg, #4b5563, #374151);
}

table {
    border-radius: 1rem;
    overflow: hidden;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

thead {
    background: linear-gradient(to right, #ede9fe, #fce7f3);
}

th, td {
    padding: 1rem;
    text-align: left;
    border-bottom: 1px solid #e5e7eb;
}

tbody tr {
    transition: background-color 0.3s ease;
}

tbody tr:hover {
    background-color: #f5f3ff;
}

.card {
    animation: slideUp 0.5s ease-out;
}

@keyframes slideUp {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
}

label {
    font-weight: 500;
    color: #374151;
}
```
   - **Note**: Ensure the file is uploaded to the static S3 bucket (section 2.4) and distributed through CloudFront (section 6).

3. **Configure the `scripts.js` File**  
   - The `scripts.js` file handles the logic for making API calls with jQuery, including data validation, HTML escaping, and handling responses/errors.  

```javascript
var API_ENDPOINT = "https://710o05k9b6.execute-api.us-east-1.amazonaws.com/prod";
var API_KEY = "hWKpVcoY6246mLB7DdrYb3nWRsYqnLBp35zIxZcd";

// Function to escape HTML to prevent XSS
function escapeHTML(str) {
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&apos;');
}

// Handle saving student data (POST)
document.getElementById("savestudent").onclick = function () {
    var inputData = {
        studentid: $('#studentid').val(),
        name: $('#name').val(),
        class: $('#class').val(),
        birthdate: $('#birthdate').val(),
        email: $('#email').val()
    };

    // Validate fields and email format
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!inputData.studentid || !inputData.name || !inputData.class || !inputData.birthdate || !inputData.email) {
        alert("Please fill in all the fields.");
        return;
    }
    if (!emailPattern.test(inputData.email)) {
        alert("Invalid email format.");
        return;
    }

    console.log("POST data:", { body: JSON.stringify(inputData) });

    $.ajax({
        url: API_ENDPOINT,
        type: 'POST',
        data: JSON.stringify({ body: JSON.stringify(inputData) }),
        contentType: 'application/json',
        headers: {
            'x-api-key': API_KEY
        },
        success: function (response) {
            console.log("POST response:", response);
            let message = "Student data has been saved!";
            if (response && response.statusCode === 400) {
                try {
                    const error = JSON.parse(response.body || "{}");
                    message = `Error: ${escapeHTML(error.message || "Unknown error")}`;
                } catch (e) {
                    console.error("Body parsing error:", e);
                    message = "Error: Unknown";
                }
            } else if (response && typeof response.body === 'string') {
                try {
                    const data = JSON.parse(response.body);
                    if (data && data.name && data.studentid) {
                        message = `Saved student: ${escapeHTML(data.name)} (${escapeHTML(data.studentid)})`;
                    } else {
                        console.warn("Response body doesn't contain name or studentid:", data);
                    }
                } catch (e) {
                    console.error("Body parsing error:", e);
                }
            } else {
                console.warn("No body or non-string body response:", response);
            }
            document.getElementById("studentSaved").textContent = message;
        },
        error: function (xhr) {
            let errorMessage = "Unknown";
            try {
                const error = JSON.parse(xhr.responseText || "{}");
                errorMessage = error.message || errorMessage;
            } catch (e) {
                errorMessage = xhr.responseText || errorMessage;
            }
            alert("Error while saving: " + errorMessage);
        }
    });
};

// Handle fetching all students (GET)
document.getElementById("getstudents").onclick = function () {
    $.ajax({
        url: API_ENDPOINT,
        type: 'GET',
        contentType: 'application/json',
        headers: {
            'x-api-key': API_KEY
        },
        success: function (response) {
            console.log("GET response:", response); // Log for debugging
            $('#studentTable tbody').empty();
            let students = response;
            // Check if the response is an object containing body
            if (response && typeof response.body === 'string') {
                try {
                    students = JSON.parse(response.body);
                } catch (e) {
                    console.error("Body parsing error:", e);
                    alert("Returned data is not in JSON format.");
                    return;
                }
            }
            // Check if students is an array
            if (Array.isArray(students)) {
                if (students.length === 0) {
                    alert("No student data.");
                } else {
                    jQuery.each(students, function (i, data) {
                        $("#studentTable tbody").append(
                            `<tr>
                                <td class='p-4'>${escapeHTML(data.studentid)}</td>
                                <td class='p-4'>${escapeHTML(data.name)}</td>
                                <td class='p-4'>${escapeHTML(data.class)}</td>
                                <td class='p-4'>${escapeHTML(data.birthdate)}</td>
                                <td class='p-4'>${escapeHTML(data.email)}</td>
                            </tr>`
                        );
                    });
                }
            } else {
                console.warn("Returned data is not an array:", students);
                alert("Returned data is not in the correct format.");
            }
        },
        error: function (xhr) {
            let errorMessage = "Unknown";
            try {
                const error = JSON.parse(xhr.responseText || "{}");
                errorMessage = error.message || errorMessage;
            } catch (e) {
                errorMessage = xhr.responseText || errorMessage;
            }
            alert("Error fetching student data: " + errorMessage);
        }
    });
};

document.getElementById("backupstudents").onclick = function(){
    $.ajax({
        url: API_ENDPOINT + "/backup",
        type: 'POST',
        data: JSON.stringify({}),
        contentType: 'application/json; charset=utf-8',
        headers: {
            'x-api-key': API_KEY
        },
        success: function (response) {
            alert("Backup successful! Check your email for the backup file.");
        },
        error: function () {
            alert("Error performing data backup.");
        }
    });
};
```
   - **Note**: Ensure to replace `API_ENDPOINT` and `API_KEY` with actual values from section 4.8 and 4.2.

4. **Replace `API_ENDPOINT` and `API_KEY`**  
   - **API_ENDPOINT**:  
     - Replace `https://abc123.execute-api.us-east-1.amazonaws.com/prod` with the **Invoke URL** from section 4.8 (retrieve from API Gateway > Stages > `prod` > Invoke URL).  
   - **API_KEY**:  
     - Replace `xxxxxxxxxxxxxxxxxxxx` with the `StudentApiKey` value from section 4.2.  
     - For better security, store `StudentApiKey` in AWS Secrets Manager and retrieve it in a serverless environment (e.g., Lambda or CloudFront Functions).  
     - **Example to retrieve API Key from AWS Secrets Manager**:  
       ```javascript
       const AWS = require('aws-sdk');
       const secretsManager = new AWS.SecretsManager({ region: 'us-east-1' });
       async function getApiKey() {
           const data = await secretsManager.getSecretValue({ SecretId: 'student-api-key' }).promise();
           return JSON.parse(data.SecretString).apiKey;
       }
       ```  
     - In the client-side environment, store `API_KEY` in environment variables (e.g., `.env` with Vite/React) or configure CloudFront to automatically add the `x-api-key` header.

---

## Important Notes

| **Factor** | **Details** |
|------------|-------------|
| **API Key Security** | Do not hardcode `API_KEY` directly in `scripts.js`. Use AWS Secrets Manager or CloudFront Functions to add the `x-api-key` header automatically. |
| **CORS** | Ensure CORS is correctly enabled (section 4.7) with `Access-Control-Allow-Origin: https://d12345678.cloudfront.net`. If encountering CORS errors, check headers in Method Response and Lambda (sections 3.1, 3.2, 3.3). |
| **AWS Region** | Ensure the region `us-east-1` matches with `student` API, stage `prod`, Lambda functions, DynamoDB `studentData`, S3 `student-backup-20250706`, SES, and CloudFront. |
| **Optimization** | - Minimize the `styles.css` and `scripts.js` files before uploading them to S3 to speed up loading. <br> - Use CloudFront cache to store static content, set a reasonable TTL (e.g., 86400 seconds). <br> - Add Request Validator in API Gateway (section 4.5) to check the JSON body of **POST /students**. <br> - Enable CloudWatch Logs for API Gateway (section 4.8): In API Gateway > Stages > `prod` > Logs/Tracing, select **Enable CloudWatch Logs**. |
| **Error Checking** | - If the interface doesn’t load: Check S3 public access and CloudFront origin. <br> - If the API returns `403`: Check `StudentApiKey` and `StudentUsagePlan` (section 4.9). <br> - If the API returns `429`: Check the limits in `StudentUsagePlan` (section 4.3). <br> - If the API returns `500`: Check the CloudWatch logs for Lambda. <br> - If the table is empty or data isn’t displaying: Check the response from **GET /students** in **Developer Tools > Network**. |
| **API Integration Testing** | - Use **Developer Tools** to check API requests. <br> - Check DynamoDB `studentData` to verify new records. <br> - Check S3 `student-backup-20250706` to verify the backup file. <br> - Check email (including Spam/Junk) to verify notifications from SES. |

> **Best Practice Tip**: Before deploying to S3, test the interface locally using `npx serve` or a static server to ensure that API requests work correctly. Use **Developer Tools > Network** to verify the `x-api-key` header and the response from the API. Check the data in DynamoDB, S3, and SES after each action.

---

## Conclusion

The web interface has been built with `index.html`, `styles.css`, and `scripts.js`, successfully integrated with the `student` API (stage `prod`) using Invoke URL and `StudentApiKey`. The application supports data entry, displays a list of students, and performs data backup, ready to be deployed on S3 and distributed through CloudFront.

> **Next step**: Proceed to [Configuring CloudFront and Deploying the Web Interface](6-configuring-s3-buckets/) to complete the integration!
