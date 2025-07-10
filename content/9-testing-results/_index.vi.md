---
title: "Kiểm Tra Kết Quả Hệ Thống"
date: 2025-07-09
weight: 9
chapter: false
pre: "<b>9. </b>"
---

> **Mục tiêu**: Kiểm tra toàn bộ hệ thống serverless, bao gồm giao diện web (phục vụ qua CloudFront `StudentWebsiteDistribution`), các chức năng lưu dữ liệu sinh viên (**POST /students**), xem danh sách sinh viên (**GET /students**), gửi email thông báo qua Amazon SES, và backup tự động từ DynamoDB `studentData` vào S3 Bucket `student-backup-20250706`. Đảm bảo hệ thống hoạt động đúng từ giao diện đến backend, email thông báo, và backup tự động.

---

## Tổng Quan về Kiểm Tra Kết Quả

- **Giao diện web**:  
  - Phân phối qua CloudFront `StudentWebsiteDistribution` (mục 7.1–7.3) từ S3 Bucket `student-management-website-2025` (mục 6.1–6.4).  
  - Sử dụng Tailwind CSS (mục 5) để hiển thị form nhập thông tin sinh viên (`studentid`, `name`, `class`, `birthdate`, `email`) và bảng danh sách.  
  - Gọi API `student` (stage `prod`, mục 4.8) với **Invoke URL** (VD: `https://abc123.execute-api.us-east-1.amazonaws.com/prod`) và `StudentApiKey` (mục 4.2).  
- **Chức năng backend**:  
  - **POST /students**: Hàm Lambda `insertStudentData` (mục 3.2) lưu bản ghi vào DynamoDB `studentData` và gửi email qua SES.  
  - **GET /students**: Hàm Lambda `getStudentData` (mục 3.1) truy xuất dữ liệu từ DynamoDB.  
  - **POST /backup**: Hàm Lambda `DynamoDBBackup` (mục 8.1) lưu tệp JSON vào S3 `student-backup-20250706` và gửi email thông báo.  
  - **Backup tự động**: EventBridge Rule `DailyDynamoDBBackup` (mục 8.2) kích hoạt `DynamoDBBackup` hàng ngày lúc 07:00 AM +07.  
- **Tích hợp với hệ thống**:  
  - CORS cấu hình (mục 4.7) hỗ trợ yêu cầu từ CloudFront (VD: `https://d12345678.cloudfront.net`).  
  - Vai trò IAM `DynamoDBBackupRoleStudent` (mục 6.5) cấp quyền DynamoDB, S3, SES.  
  - Email thông báo gửi qua SES đến sinh viên và admin (`no-reply@studentapp.com`, `admin@studentapp.com`).  

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành:  
- Mục 2.4: Tạo S3 Bucket `student-backup-20250706`.  
- Mục 3.1–3.3: Tạo Lambda functions `getStudentData`, `insertStudentData`, `DynamoDBBackup` với vai trò `DynamoDBBackupRoleStudent`.  
- Mục 4.1–4.9: Tạo API `student`, `StudentApiKey`, `StudentUsagePlan`, phương thức **GET /students**, **POST /students**, **POST /backup**, kích hoạt CORS, triển khai stage `prod`.  
- Mục 5: Xây dựng giao diện web (`index.html`, `styles.css`, `scripts.js`).  
- Mục 6.1–6.5: Tạo S3 Buckets `student-management-website-2025`, `student-backup-20250706`.  
- Mục 7.1–7.3: Tạo CloudFront `StudentWebsiteDistribution`.  
- Mục 8.1–8.2: Cấu hình Lambda `DynamoDBBackup`, EventBridge Rule `DailyDynamoDBBackup`.  
Đảm bảo tài khoản AWS có quyền `dynamodb:Scan`, `dynamodb:PutItem`, `s3:GetObject`, `s3:PutObject`, `ses:SendEmail`, và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập Website qua CloudFront Domain Name**  
   - Mở trình duyệt (Chrome, Firefox) và nhập CloudFront URL (VD: `https://d12345678.cloudfront.net`) từ **CloudFront > Distributions > StudentWebsiteDistribution** (mục 7.3).  
   - **Kết quả mong đợi**:  
     - Giao diện web tải thành công, hiển thị form nhập thông tin sinh viên (`studentid`, `name`, `class`, `birthdate`, `email`) và nút **Lưu**, **Xem tất cả sinh viên**, styled bằng Tailwind CSS (mục 5).  
     - Không có lỗi JavaScript trong **Developer Tools > Console**.  
     ![Truy cập CloudFront URL.](/images/9-testing-results/testing-results-01.png)  
     *Hình 1: Truy cập CloudFront URL.*  
     ![Giao diện website.](/images/9-testing-results/testing-results-02.png)  
     *Hình 2: Giao diện website.*

2. **Nhập và Lưu Thông Tin Sinh Viên**  
   - Trong form giao diện web, nhập:  
     - **MSSV (studentid)**: `SV006`  
     - **Họ tên (name)**: `Nguyen Van F`  
     - **Lớp (class)**: `CNTT06`  
     - **Ngày sinh (birthdate)**: `2001-06-06`  
     - **Email**: `student6@example.com`  
   - Nhấn **Lưu** để gửi **POST /students** qua API Gateway.  
     ![Form nhập thông tin sinh viên.](/images/9-testing-results/testing-results-03.png)  
     *Hình 3: Form nhập thông tin sinh viên.*

3. **Xác Nhận Thông Báo Lưu Thành Công**  
   - Sau khi nhấn **Lưu**, giao diện hiển thị thông báo _"Lưu thành công"_ (xử lý bởi `scripts.js`).  
   - **Kết quả mong đợi**:  
     - Thông báo hiển thị (VD: qua `alert()` hoặc div styled bằng Tailwind CSS).  
     - Hàm `insertStudentData` trả về:  
       ```json
       { "statusCode": 200, "body": "{\"message\": \"Lưu thành công\"}" }
       ```  
     ![Thông báo lưu thành công.](/images/9-testing-results/testing-results-04.png)  
     *Hình 4: Thông báo lưu thành công.*

4. **Xem Danh Sách Sinh Viên**  
   - Nhấn **Xem tất cả sinh viên** để gửi **GET /students**.  
   - **Kết quả mong đợi**:  
     - Hàm `getStudentData` (mục 3.1) truy xuất dữ liệu từ `studentData`.  
     - Giao diện hiển thị bảng chứa bản ghi vừa nhập (`SV006`) và các bản ghi khác, với các trường: `studentid`, `name`, `class`, `birthdate`, `email`.  
     ![Bảng danh sách sinh viên.](/images/9-testing-results/testing-results-05.png)  
     *Hình 5: Bảng danh sách sinh viên.*

5. **Kiểm Tra Email Thông Báo của Sinh Viên**  
   - Mở hộp thư `student6@example.com` để kiểm tra email từ SES.  
   - **Kết quả mong đợi**:  
     - Email từ `no-reply@studentapp.com` với:  
       - **Subject**: _Thông tin sinh viên đã được lưu_  
       - **Body**:  
         ```
         Chào Nguyen Van F,
         Thông tin của bạn đã được lưu thành công:
         - MSSV: SV006
         - Lớp: CNTT06
         - Ngày sinh: 2001-06-06
         - Email: student6@example.com
         ```  
     - **Xử lý lỗi**:  
       - Email không gửi: Xác minh `no-reply@studentapp.com`, `student6@example.com` trong SES (mục 3).  
       - Kiểm tra quyền `ses:SendEmail` trong `DynamoDBBackupRoleStudent`.  
     ![Email thông báo sinh viên.](/images/9-testing-results/testing-results-06.png)  
     *Hình 6: Email thông báo sinh viên.*

6. **Kiểm Tra Dữ Liệu trong DynamoDB**  
   - Trong **AWS Management Console**, tìm **DynamoDB > Tables > studentData**.  
   - Chọn **Explore items** để xem dữ liệu.  
   - **Kết quả mong đợi**:  
     - Bản ghi mới:  
       ```json
       {
           "studentid": "SV006",
           "name": "Nguyen Van F",
           "class": "CNTT06",
           "birthdate": "2001-06-06",
           "email": "student6@example.com"
       }
       ```  
     - Các bản ghi khác hiển thị đúng.  
     - **Xử lý lỗi**:  
       - Bản ghi không xuất hiện: Kiểm tra log `/aws/lambda/insertStudentData` (mục 10) hoặc quyền `dynamodb:PutItem`.  
     ![Dữ liệu trong DynamoDB.](/images/9-testing-results/testing-results-07.png)  
     *Hình 7: Dữ liệu trong DynamoDB.*

7. **Kiểm Tra Email Thông Báo Backup của Admin**  
   - Mở hộp thư `admin@studentapp.com` để kiểm tra email backup từ SES (gửi bởi `DynamoDBBackup`, mục 8.1).  
   - **Kết quả mong đợi**:  
     - Email từ `no-reply@studentapp.com` với:  
       - **Subject**: _Student Data Backup Completed_  
       - **Body**: _Backup created at backup/students-backup-20250709T0700.json in S3 bucket student-backup-20250706_  
     - Email gửi sau khi `DynamoDBBackup` chạy (thủ công qua **POST /backup** hoặc tự động qua `DailyDynamoDBBackup` lúc 07:00 AM +07, mục 8.2).  
     - **Xử lý lỗi**:  
       - Email không gửi: Xác minh SES email và quyền `ses:SendEmail`.  
       - Kiểm tra log `/aws/lambda/DynamoDBBackup` (mục 10).  
     ![Email thông báo backup.](/images/9-testing-results/testing-results-08.png)  
     *Hình 8: Email thông báo backup.*

8. **Kiểm Tra Tệp Backup trong S3**  
   - Trong **AWS Management Console**, tìm **S3 > Buckets > student-backup-20250706**.  
   - Mở thư mục `backup/` và kiểm tra tệp JSON (VD: `students-backup-20250709T0700.json`).  
   - **Kết quả mong đợi**:  
     - Tệp JSON chứa dữ liệu từ `studentData`, bao gồm bản ghi `SV006`.  
     - **Xử lý lỗi**:  
       - Tệp không xuất hiện: Kiểm tra log `/aws/lambda/DynamoDBBackup` hoặc quyền `s3:PutObject` trong `DynamoDBBackupRoleStudent`.  
       - Xác minh `DailyDynamoDBBackup` (mục 8.2) chạy đúng lịch.  
     ![Tệp backup trong S3.](/images/9-testing-results/testing-results-09.png)  
     *Hình 9: Tệp backup trong S3.*

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Bảo mật** | - Không nhúng `StudentApiKey` trong `scripts.js`. Sử dụng CloudFront Functions: <br> ```javascript <br> function handler(event) { <br> var request = event.request; <br> request.headers['x-api-key'] = { value: 'xxxxxxxxxxxxxxxxxxxx' }; <br> return request; <br> } <br> ``` <br> - Xác minh email SES (`no-reply@studentapp.com`, `admin@studentapp.com`, `student6@example.com`). |
| **Tối ưu hóa** | - Kiểm tra CloudWatch Logs (mục 10) để phân tích hiệu suất. <br> - Sử dụng AWS CLI để test API: <br> ```bash <br> aws apigateway test-invoke-method --rest-api-id abc123 --resource-id xxxxx --http-method POST --path-with-query-string /students --body '{"studentid":"SV006","name":"Nguyen Van F","class":"CNTT06","birthdate":"2001-06-06","email":"student6@example.com"}' <br> ``` |
| **Tích hợp** | - Đảm bảo CORS trong API Gateway (mục 4.7): `Access-Control-Allow-Origin: https://d12345678.cloudfront.net`. <br> - Test tất cả endpoint (**POST /students**, **GET /students**, **POST /backup**) qua CloudFront URL. |
| **Kiểm tra tích hợp** | - Truy cập `https://d12345678.cloudfront.net`: <br> - **POST /students**: Lưu bản ghi, gửi email SES. <br> - **GET /students**: Hiển thị bảng. <br> - **POST /backup**: Tạo tệp JSON, gửi email. <br> - Dùng **Developer Tools > Network** để kiểm tra yêu cầu API. |
| **Xử lý lỗi** | - **Giao diện lỗi**: Kiểm tra `index.html`, `scripts.js` trong S3 `student-management-website-2025`. <br> - **API lỗi**: Kiểm tra log `/aws/lambda/insertStudentData`, `/aws/lambda/getStudentData`. <br> - **Backup lỗi**: Xác minh `DailyDynamoDBBackup` và log `/aws/lambda/DynamoDBBackup`. <br> - **Email lỗi**: Kiểm tra SES email và quyền `ses:SendEmail`. |

> **Mẹo thực tiễn**: Test từng chức năng qua giao diện web. Kiểm tra CloudWatch Logs (mục 10) để gỡ lỗi. Đặt S3 Lifecycle Rule cho `student-backup-20250706` để quản lý tệp cũ.

---

## Kết Luận

Hệ thống serverless hoạt động đúng: giao diện web tải qua CloudFront, **POST /students** lưu dữ liệu và gửi email, **GET /students** hiển thị danh sách, **POST /backup** và `DailyDynamoDBBackup` tạo tệp JSON trong S3, email thông báo gửi thành công. Tất cả tích hợp mượt mà với API `student` và SES.

> **Bước tiếp theo**: Chuyển đến [Xem Logs Hoạt Động Bằng CloudWatch](/10-monitoring-logs-with-cloudwatch/) để phân tích chi tiết và tối ưu hóa!