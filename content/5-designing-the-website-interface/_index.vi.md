---
title: "Viết giao diện cho Website"
date: 2023-10-25
weight: 5
chapter: false
pre: "<b>5. </b>"
---

> **Mục tiêu**: Xây dựng giao diện web cho ứng dụng Quản Lý Dữ Liệu Sinh Viên sử dụng HTML, Tailwind CSS, và JavaScript (với jQuery) để:  
> - Cho phép người dùng nhập và lưu thông tin sinh viên (mã sinh viên, họ tên, lớp, ngày sinh, email) qua endpoint **POST /students**.  
> - Hiển thị danh sách sinh viên từ endpoint **GET /students**.  
> - Kích hoạt sao lưu dữ liệu qua endpoint **POST /backup**.  
> Giao diện sẽ được triển khai trên Amazon S3 (bucket tĩnh, mục 2.4) và phân phối qua CloudFront (mục 6), tích hợp với API `student` (stage `prod`, mục 4.8) sử dụng Invoke URL và API Key `StudentApiKey` (mục 4.2) với bảo mật CORS (mục 4.7).

---

## Tổng Quan về Giao Diện Web

- **index.html**: Cung cấp cấu trúc giao diện với biểu mẫu nhập liệu, các nút chức năng (Lưu Dữ Liệu Sinh Viên, Xem Tất Cả Sinh Viên, Backup Dữ Liệu), và bảng hiển thị danh sách sinh viên.  
- **styles.css**: Sử dụng Tailwind CSS và tùy chỉnh với font Poppins, gradient màu sắc, hiệu ứng động, và thiết kế responsive.  
- **scripts.js**: Xử lý logic gọi API (**GET /students**, **POST /students**, **POST /backup**) với jQuery, bao gồm kiểm tra dữ liệu đầu vào, mã hóa HTML để ngăn XSS, và xử lý phản hồi/lỗi từ API.  
- **Tích hợp AWS**:  
  - Thay thế `API_ENDPOINT` bằng Invoke URL (ví dụ: `https://abc123.execute-api.us-east-1.amazonaws.com/prod`) từ mục 4.8.  
  - Thay thế `API_KEY` bằng giá trị `StudentApiKey` từ mục 4.2, lưu trữ an toàn trong AWS Secrets Manager hoặc biến môi trường.  
- **Cải tiến**:  
  - Tăng cường bảo mật bằng cách lưu `API_KEY` trong AWS Secrets Manager.  
  - Cải thiện trải nghiệm người dùng với thông báo giao diện (thay vì alert).  
  - Thêm kiểm tra dữ liệu đầu vào chặt chẽ hơn.  
  - Tối ưu hóa responsive và hiệu ứng động.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành mục 2.4 (tạo bucket S3 tĩnh), mục 4.1 (tạo API `student`), mục 4.2 (tạo API Key `StudentApiKey`), mục 4.3 (tạo Usage Plan `StudentUsagePlan`), mục 4.4 (tạo phương thức **GET /students**), mục 4.5 (tạo phương thức **POST /students**), mục 4.6 (tạo resource `/backup` và phương thức **POST /backup**), mục 4.7 (kích hoạt CORS), mục 4.8 (triển khai API lên stage `prod`), mục 4.9 (gắn `StudentApiKey` vào `StudentUsagePlan` và liên kết với API `student` stage `prod`), và mục 3 (tạo các hàm Lambda `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, SES email xác minh). Đảm bảo tài khoản AWS đã sẵn sàng và vùng AWS là `us-east-1`. Cần có quyền truy cập S3, CloudFront, và API Gateway.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Cấu Hình Tệp `index.html`**  
   - Tệp `index.html` định nghĩa giao diện với biểu mẫu nhập liệu, các nút chức năng, và bảng hiển thị sinh viên.  

```html
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Dữ Liệu Sinh Viên</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="styles.css">
</head>
<body class="min-h-screen flex items-center justify-center p-6">
    <div class="form-container card">
        <h1 class="text-4xl font-bold text-center mb-8">Quản Lý Sinh Viên</h1>
        <div class="space-y-6">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                    <label for="studentid" class="block text-sm mb-1">Mã Sinh Viên</label>
                    <input type="text" name="studentid" id="studentid" class="w-full" placeholder="Nhập mã sinh viên">
                </div>
                <div>
                    <label for="name" class="block text-sm mb-1">Họ Tên</label>
                    <input type="text" name="name" id="name" class="w-full" placeholder="Nhập họ tên">
                </div>
                <div>
                    <label for="class" class="block text-sm mb-1">Lớp</label>
                    <input type="text" name="class" id="class" class="w-full" placeholder="Nhập lớp">
                </div>
                <div>
                    <label for="birthdate" class="block text-sm mb-1">Ngày Sinh</label>
                    <input type="date" name="birthdate" id="birthdate" class="w-full">
                </div>
                <div class="md:col-span-2">
                    <label for="email" class="block text-sm mb-1">Email</label>
                    <input type="text" name="email" id="email" class="w-full" placeholder="Nhập email">
                </div>
            </div>
            <button id="savestudent" class="btn-primary w-full">Lưu Dữ Liệu Sinh Viên</button>
            <p id="studentSaved" class="text-center text-green-600 font-medium text-lg"></p>
            <button id="getstudents" class="btn-primary btn-secondary w-full">Xem Tất Cả Sinh Viên</button>
	<button id="backupstudents" class="btn-primary w-full bg-green-600 text-white p-3 rounded-xl font-semibold hover:bg-green-700">Backup Dữ Liệu</button>
        </div>
        <div id="showStudents" class="mt-8 overflow-x-auto">
            <table id="studentTable" class="w-full">
                <thead>
                    <tr>
                        <th class="text-sm font-semibold">Mã Sinh Viên</th>
                        <th class="text-sm font-semibold">Họ Tên</th>
                        <th class="text-sm font-semibold">Lớp</th>
                        <th class="text-sm font-semibold">Ngày Sinh</th>
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

   - **Lưu ý**: Đảm bảo tệp được tải lên bucket S3 tĩnh (mục 2.4) và phân phối qua CloudFront (mục 6).

2. **Cấu Hình Tệp `styles.css`**  
   - Tệp `styles.css` tùy chỉnh giao diện với Tailwind CSS, font Poppins, và hiệu ứng động.  

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

   - **Lưu ý**: Nén tệp `styles.css` trước khi tải lên S3 để tăng tốc độ tải.

3. **Cấu Hình Tệp `scripts.js`**  
   - Tệp `scripts.js` xử lý logic gọi API với jQuery, bao gồm kiểm tra dữ liệu, mã hóa HTML, và xử lý phản hồi/lỗi.  
   
```javascript
var API_ENDPOINT = "https://710o05k9b6.execute-api.us-east-1.amazonaws.com/prod";
var API_KEY = "hWKpVcoY6246mLB7DdrYb3nWRsYqnLBp35zIxZcd";

// Hàm mã hóa HTML để ngăn XSS
function escapeHTML(str) {
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&apos;');
}

// Xử lý lưu dữ liệu sinh viên (POST)
document.getElementById("savestudent").onclick = function () {
    var inputData = {
        studentid: $('#studentid').val(),
        name: $('#name').val(),
        class: $('#class').val(),
        birthdate: $('#birthdate').val(),
        email: $('#email').val()
    };

    // Kiểm tra rỗng và định dạng email
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!inputData.studentid || !inputData.name || !inputData.class || !inputData.birthdate || !inputData.email) {
        alert("Vui lòng nhập đầy đủ thông tin.");
        return;
    }
    if (!emailPattern.test(inputData.email)) {
        alert("Email không hợp lệ.");
        return;
    }

    console.log("Dữ liệu gửi POST:", { body: JSON.stringify(inputData) });

    $.ajax({
        url: API_ENDPOINT,
        type: 'POST',
        data: JSON.stringify({ body: JSON.stringify(inputData) }),
        contentType: 'application/json',
        headers: {
            'x-api-key': API_KEY
        },
        success: function (response) {
            console.log("Phản hồi POST:", response);
            let message = "Dữ liệu sinh viên đã được lưu!";
            if (response && response.statusCode === 400) {
                try {
                    const error = JSON.parse(response.body || "{}");
                    message = `Lỗi: ${escapeHTML(error.message || "Không xác định")}`;
                } catch (e) {
                    console.error("Lỗi phân tích body:", e);
                    message = "Lỗi: Không xác định";
                }
            } else if (response && typeof response.body === 'string') {
                try {
                    const data = JSON.parse(response.body);
                    if (data && data.name && data.studentid) {
                        message = `Đã lưu sinh viên: ${escapeHTML(data.name)} (${escapeHTML(data.studentid)})`;
                    } else {
                        console.warn("Dữ liệu body không chứa name hoặc studentid:", data);
                    }
                } catch (e) {
                    console.error("Lỗi phân tích body:", e);
                }
            } else {
                console.warn("Phản hồi không có body hoặc body không phải chuỗi:", response);
            }
            document.getElementById("studentSaved").textContent = message;
        },
        error: function (xhr) {
            let errorMessage = "Không xác định";
            try {
                const error = JSON.parse(xhr.responseText || "{}");
                errorMessage = error.message || errorMessage;
            } catch (e) {
                errorMessage = xhr.responseText || errorMessage;
            }
            alert("Lỗi khi lưu: " + errorMessage);
        }
    });
};

// Xử lý lấy danh sách sinh viên (GET)
document.getElementById("getstudents").onclick = function () {
    $.ajax({
        url: API_ENDPOINT,
        type: 'GET',
        contentType: 'application/json',
        headers: {
            'x-api-key': API_KEY
        },
        success: function (response) {
            console.log("Phản hồi GET:", response); // Ghi log để kiểm tra
            $('#studentTable tbody').empty();
            let students = response;
            // Kiểm tra nếu response là đối tượng chứa body
            if (response && typeof response.body === 'string') {
                try {
                    students = JSON.parse(response.body);
                } catch (e) {
                    console.error("Lỗi phân tích body:", e);
                    alert("Dữ liệu trả về không đúng định dạng JSON.");
                    return;
                }
            }
            // Kiểm tra nếu students là mảng
            if (Array.isArray(students)) {
                if (students.length === 0) {
                    alert("Không có dữ liệu sinh viên.");
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
                console.warn("Dữ liệu trả về không phải mảng:", students);
                alert("Dữ liệu trả về không đúng định dạng.");
            }
        },
        error: function (xhr) {
            let errorMessage = "Không xác định";
            try {
                const error = JSON.parse(xhr.responseText || "{}");
                errorMessage = error.message || errorMessage;
            } catch (e) {
                errorMessage = xhr.responseText || errorMessage;
            }
            alert("Lỗi khi lấy dữ liệu sinh viên: " + errorMessage);
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
            alert("Backup dữ liệu thành công! Kiểm tra email để tải file backup.");
        },
        error: function () {
            alert("Lỗi khi thực hiện backup dữ liệu.");
        }
    });
};
```

   - **Lưu ý**: Đảm bảo thay `API_ENDPOINT` và `API_KEY` bằng giá trị thực từ mục 4.8 và 4.2.

4. **Thay Thế `API_ENDPOINT` và `API_KEY`**  
   - **API_ENDPOINT**:  
     - Thay `https://abc123.execute-api.us-east-1.amazonaws.com/prod` bằng **Invoke URL** từ mục 4.8 (lấy từ API Gateway > Stages > `prod` > Invoke URL).  
   - **API_KEY**:  
     - Thay `xxxxxxxxxxxxxxxxxxxx` bằng giá trị `StudentApiKey` từ mục 4.2.  
     - Để tăng bảo mật, lưu `StudentApiKey` trong AWS Secrets Manager và truy xuất trong môi trường serverless (ví dụ: Lambda hoặc CloudFront Functions).  
     - **Ví dụ truy xuất API Key từ AWS Secrets Manager**:  
       ```javascript
       const AWS = require('aws-sdk');
       const secretsManager = new AWS.SecretsManager({ region: 'us-east-1' });
       async function getApiKey() {
           const data = await secretsManager.getSecretValue({ SecretId: 'student-api-key' }).promise();
           return JSON.parse(data.SecretString).apiKey;
       }
       ```  
     - Trong môi trường client-side, lưu `API_KEY` trong biến môi trường (ví dụ: `.env` với Vite/React) hoặc cấu hình CloudFront để thêm header `x-api-key` tự động.

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Bảo mật API Key** | Không nhúng `API_KEY` trực tiếp trong `scripts.js`. Sử dụng AWS Secrets Manager hoặc CloudFront Functions để thêm header `x-api-key` tự động. |
| **CORS** | Đảm bảo CORS được kích hoạt đúng (mục 4.7) với `Access-Control-Allow-Origin: https://d12345678.cloudfront.net`. Nếu gặp lỗi CORS, kiểm tra header trong Method Response và Lambda (mục 3.1, 3.2, 3.3). |
| **Vùng AWS** | Đảm bảo vùng `us-east-1` khớp với API `student`, stage `prod`, các hàm Lambda, DynamoDB `studentData`, S3 `student-backup-20250706`, SES, và CloudFront. |
| **Tối ưu hóa** | - Nén tệp `styles.css` và `scripts.js` trước khi tải lên S3 để tăng tốc độ tải. <br> - Sử dụng CloudFront cache để lưu trữ nội dung tĩnh, đặt TTL hợp lý (VD: 86400 giây). <br> - Thêm Request Validator trong API Gateway (mục 4.5) để kiểm tra JSON body của **POST /students**. <br> - Bật CloudWatch Logs cho API Gateway (mục 4.8): Trong API Gateway > Stages > `prod` > Logs/Tracing, chọn **Enable CloudWatch Logs**. |
| **Kiểm tra lỗi** | - Nếu giao diện không tải: Kiểm tra quyền S3 public và CloudFront origin. <br> - Nếu API trả lỗi `403`: Kiểm tra `StudentApiKey` và `StudentUsagePlan` (mục 4.9). <br> - Nếu API trả lỗi `429`: Kiểm tra giới hạn trong `StudentUsagePlan` (mục 4.3). <br> - Nếu API trả lỗi `500`: Kiểm tra log CloudWatch của Lambda. <br> - Nếu bảng rỗng hoặc dữ liệu không hiển thị: Kiểm tra phản hồi từ **GET /students** trong **Developer Tools > Network**. |
| **Kiểm tra tích hợp với API** | - Sử dụng **Developer Tools** để kiểm tra yêu cầu API. <br> - Kiểm tra DynamoDB `studentData` để xác minh bản ghi mới. <br> - Kiểm tra S3 `student-backup-20250706` để xác minh tệp backup. <br> - Kiểm tra email (bao gồm Spam/Junk) để xác minh thông báo từ SES. |

> **Mẹo thực tiễn**: Trước khi triển khai lên S3, kiểm tra giao diện cục bộ bằng `npx serve` hoặc server tĩnh để đảm bảo các yêu cầu API hoạt động đúng. Sử dụng **Developer Tools > Network** để xác minh header `x-api-key` và phản hồi từ API. Kiểm tra dữ liệu trong DynamoDB, S3, và SES sau mỗi hành động.

---

## Kết Luận

Giao diện web đã được xây dựng với `index.html`, `styles.css`, và `scripts.js`, tích hợp thành công với API `student` (stage `prod`) thông qua Invoke URL và `StudentApiKey`. Ứng dụng hỗ trợ nhập liệu, hiển thị danh sách sinh viên, và sao lưu dữ liệu, sẵn sàng triển khai trên S3 và phân phối qua CloudFront.

> **Bước tiếp theo**: Chuyển đến [Cấu hình CloudFront và triển khai giao diện web](6-configuring-s3-buckets/) để hoàn thiện tích hợp!
