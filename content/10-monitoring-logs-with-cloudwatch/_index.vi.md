---
title: "Xem Logs Hoạt Động Bằng CloudWatch"
date: 2025-07-09
weight: 10
chapter: false
pre: "<b>10. </b>"
---

> **Mục tiêu**: Sử dụng Amazon CloudWatch để xem và quản lý logs hoạt động của các Lambda function (`DynamoDBBackup`, `getStudentData`, `insertStudentData`) trong hệ thống serverless. Tập trung kiểm tra logs của hàm `insertStudentData` (tích hợp với endpoint **POST /students**, mục 4.5) để theo dõi lưu dữ liệu sinh viên vào DynamoDB `studentData` và gửi email qua Amazon SES. Logs giúp xác minh chức năng, phát hiện lỗi, và tối ưu hóa hiệu suất.

---

## Tổng Quan về CloudWatch Logs

- **Vai trò của CloudWatch Logs**:  
  - Thu thập và lưu trữ logs từ Lambda functions (`DynamoDBBackup`, `getStudentData`, `insertStudentData`) trong Log Groups để theo dõi hoạt động, gỡ lỗi, và giám sát hiệu suất.  
  - Hàm `insertStudentData` (mục 3.2) xử lý **POST /students**, lưu bản ghi (studentid, name, class, birthdate, email) vào DynamoDB `studentData` và gửi email xác nhận qua SES.  
  - Logs ghi lại:  
    - Yêu cầu API thành công (statusCode: 200).  
    - Lỗi (VD: AccessDenied, ValidationException).  
    - Hiệu suất (Duration, Memory Used).  
- **Tích hợp với hệ thống**:  
  - Giao diện web (CloudFront `StudentWebsiteDistribution`, mục 7.1–7.3) từ S3 `student-management-website-2025` (mục 6.1–6.4) gọi API `student` (stage `prod`, mục 4.8) với **Invoke URL** (VD: `https://abc123.execute-api.us-east-1.amazonaws.com/prod`) và `StudentApiKey` (mục 4.2).  
  - Các chức năng:  
    - **POST /students**: Lưu bản ghi, gửi email SES.  
    - **GET /students**: Hiển thị dữ liệu từ `getStudentData`.  
    - **POST /backup**: Lưu tệp JSON vào `student-backup-20250706` (mục 6.5) qua `DynamoDBBackup` (mục 8.1).  
  - CORS cấu hình (mục 4.7) hỗ trợ yêu cầu từ CloudFront (VD: `https://d12345678.cloudfront.net`).  
  - Vai trò `DynamoDBBackupRoleStudent` (mục 6.5) cấp quyền DynamoDB, S3, SES.  
  - EventBridge Rule `DailyDynamoDBBackup` (mục 8.2) chạy backup lúc 07:00 AM +07.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành:  
- Mục 2.4: Tạo S3 Bucket `student-backup-20250706`.  
- Mục 3.2–3.3: Tạo Lambda functions `getStudentData`, `insertStudentData`, `DynamoDBBackup` với vai trò `DynamoDBBackupRoleStudent`.  
- Mục 4.1–4.9: Tạo API `student`, `StudentApiKey`, `StudentUsagePlan`, phương thức **GET /students**, **POST /students**, **POST /backup**, kích hoạt CORS, triển khai stage `prod`.  
- Mục 5: Xây dựng giao diện web (`index.html`, `styles.css`, `scripts.js`).  
- Mục 6.1–6.5: Tạo S3 Buckets `student-management-website-2025`, `student-backup-20250706`.  
- Mục 7.1–7.3: Tạo CloudFront `StudentWebsiteDistribution`.  
- Mục 8.1–8.2: Cấu hình Lambda `DynamoDBBackup`, EventBridge Rule `DailyDynamoDBBackup`.  
Đảm bảo tài khoản AWS có quyền `logs:DescribeLogGroups`, `logs:DescribeLogStreams`, `logs:GetLogEvents`, `logs:StartQuery`, và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console và CloudWatch**  
   - Đăng nhập **[AWS Management Console](https://console.aws.amazon.com)**.  
   - Tìm **CloudWatch**, chọn **Amazon CloudWatch**.  
   - Xác minh vùng AWS: `us-east-1` để đồng bộ với DynamoDB `studentData`, S3 (`student-management-website-2025`, `student-backup-20250706`), Lambda, API Gateway, SES, CloudFront.  
     ![Giao diện AWS Console với thanh tìm kiếm CloudWatch.](/images/10-monitoring-logs-with-cloudwatch/monitoring-logs-with-cloudwatch-01.png)
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm CloudWatch.*

2. **Chọn Log Groups**  
   - Trong **CloudWatch**, chọn **Log groups** từ menu bên trái.  
   - Kiểm tra: Xác minh các Log Groups tồn tại:  
     - `/aws/lambda/DynamoDBBackup` (cho **POST /backup**, mục 8.1).  
     - `/aws/lambda/getStudentData` (cho **GET /students**, mục 4.4).  
     - `/aws/lambda/insertStudentData` (cho **POST /students**, mục 4.5).  
     ![Danh sách Log Groups.](/images/10-monitoring-logs-with-cloudwatch/monitoring-logs-with-cloudwatch-02.png)
     *Hình 2: Danh sách Log Groups.*

3. **Chọn Log Group của Lambda insertStudentData**  
   - Trong **Log groups**, nhấp vào `/aws/lambda/insertStudentData`.  
   - **Nhận diện**: Chứa logs của hàm `insertStudentData`, ghi lại hoạt động **POST /students** (lưu bản ghi vào `studentData`, gửi email SES).  
   - Kích hoạt hàm (nếu chưa có log): Gửi yêu cầu API:  
     ```bash
     curl -X POST https://abc123.execute-api.us-east-1.amazonaws.com/prod/students \
         -H "x-api-key: xxxxxxxxxxxxxxxxxxxx" \
         -H "Content-Type: application/json" \
         -d '{"studentid":"SV005","name":"Pham Thi E","class":"CNTT05","birthdate":"2001-05-05","email":"student5@example.com"}'
     ```  
     ![Giao diện Log Group insertStudentData.](/images/10-monitoring-logs-with-cloudwatch/monitoring-logs-with-cloudwatch-03.png)
     *Hình 3: Giao diện Log Group insertStudentData.*

4. **Xem Log Streams**  
   - Trong `/aws/lambda/insertStudentData`, xem danh sách **Log Streams** (VD: `2025/07/09/[$LATEST]abc123`).  
   - Nhấp vào **Log Stream** gần nhất (dựa trên **Last Event Time**) để xem chi tiết.  
   - Kiểm tra: Log Streams được tạo từ:  
     - Yêu cầu **POST /students** qua CloudFront (`https://d12345678.cloudfront.net`).  
     - Test thủ công trong Lambda Console (mục 3.2).  
     ![Danh sách Log Streams.](/images/10-monitoring-logs-with-cloudwatch/monitoring-logs-with-cloudwatch-04.png)
     *Hình 4: Danh sách Log Streams.*

5. **Phân Tích Thông Tin trong Log Stream**  
   - Trong **Log Stream**, kiểm tra:  
     - **START RequestId**: Bắt đầu thực thi.  
     - **END RequestId**: Kết thúc thực thi.  
     - **REPORT RequestId**: Hiệu suất (Duration, Billed Duration, Memory Used, Max Memory Used).  
     - **Tùy chỉnh**: Logs từ `console.log` (VD: _Successfully saved to DynamoDB_).  
     - **Lỗi**: AccessDenied, ValidationException, SES error.  
   - **Phân tích**:  
     - **Thành công**: Log hiển thị dữ liệu lưu vào `studentData`, email gửi qua SES. Xác minh bản ghi (VD: `SV005`) trong DynamoDB và email tại `student5@example.com`.  
     - **Hiệu suất**: Duration ~456 ms, Memory Used ~72 MB (trong giới hạn 128 MB, mục 8.1).  
     - **Lỗi tiềm năng**:  
       - **AccessDenied**: Thiếu quyền `dynamodb:PutItem`, `ses:SendEmail` trong `DynamoDBBackupRoleStudent`.  
       - **ValidationException**: Dữ liệu đầu vào không hợp lệ (VD: thiếu `studentid`).  
       - **SES error**: Email `no-reply@studentapp.com` hoặc `student5@example.com` chưa xác thực trong SES.  
     ![Chi tiết Log Stream.](/images/10-monitoring-logs-with-cloudwatch/monitoring-logs-with-cloudwatch-05.png)
     *Hình 5: Chi tiết Log Stream.*

6. **Sử Dụng CloudWatch Logs Insights**  
   - Trong **CloudWatch > Logs > Logs Insights**, chọn `/aws/lambda/insertStudentData`.  
   - Truy vấn thành công:  
     ```log
     fields @timestamp, @message
     | filter @message like /Successfully saved to DynamoDB/
     | sort @timestamp desc
     | limit 20
     ```  
   - Truy vấn lỗi:  
     ```log
     fields @timestamp, @message
     | filter @message like /ERROR/
     | sort @timestamp desc
     | limit 20
     ```  
   - Nhấn **Run query**.  
   - **Kết quả**: Hiển thị logs với thời gian, thông báo, chi tiết lỗi (nếu có).  
   - **Xử lý lỗi**:  
     - **AccessDenied**: Kiểm tra quyền `dynamodb:PutItem`, `ses:SendEmail` trong `DynamoDBBackupRoleStudent`:  
       ```json
       {
           "Version": "2012-10-17",
           "Statement": [
               {
                   "Effect": "Allow",
                   "Action": [
                       "dynamodb:PutItem",
                       "ses:SendEmail"
                   ],
                   "Resource": [
                       "arn:aws:dynamodb:us-east-1:<AWS_ACCOUNT_ID>:table/studentData",
                       "arn:aws:ses:us-east-1:<AWS_ACCOUNT_ID>:identity/*"
                   ]
               }
           ]
       }
       ```  
       Thay `<AWS_ACCOUNT_ID>` bằng ID tài khoản AWS.  
     - **ValidationException**: Kiểm tra dữ liệu đầu vào API (VD: `studentid`, `name` không rỗng).  
     - **SES error**: Xác minh email trong SES (mục 3).  
     - **No logs**: Đảm bảo hàm được kích hoạt và CloudWatch Logs được bật (mục 8.1).  
     ![CloudWatch Logs Insights.](/images/10-monitoring-logs-with-cloudwatch/monitoring-logs-with-cloudwatch-06.png)
     *Hình 6: CloudWatch Logs Insights.*

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Bảo mật** | - Đảm bảo vai trò `DynamoDBBackupRoleStudent` chỉ cấp quyền cần thiết (`dynamodb:PutItem`, `ses:SendEmail`). <br> - Không nhúng `StudentApiKey` trong `scripts.js`. Sử dụng CloudFront Functions: <br> ```javascript <br> function handler(event) { <br> var request = event.request; <br> request.headers['x-api-key'] = { value: 'xxxxxxxxxxxxxxxxxxxx' }; <br> return request; <br> } <br> ``` |
| **Tối ưu hóa** | - Bật CloudWatch Logs cho Lambda (mục 8.1). <br> - Sử dụng AWS CLI để kiểm tra logs: <br> ```bash <br> aws logs describe-log-streams --log-group-name /aws/lambda/insertStudentData <br> ``` |
| **Tích hợp** | - Xác minh CORS trong API Gateway (mục 4.7): `Access-Control-Allow-Origin: https://d12345678.cloudfront.net`. <br> - Test **POST /students** qua CloudFront URL để tạo log mới. |
| **Kiểm tra tích hợp** | - Truy cập CloudFront URL (`https://d12345678.cloudfront.net`): <br> - **POST /students**: Lưu bản ghi, gửi email SES. <br> - **GET /students**: Hiển thị bảng. <br> - **POST /backup**: Tạo tệp trong `student-backup-20250706`, gửi email. <br> - Dùng **Developer Tools > Network** để kiểm tra yêu cầu API. |
| **Xử lý lỗi** | - **No logs**: Kiểm tra CloudWatch Logs bật trong Lambda, kích hoạt hàm qua API. <br> - **AccessDenied**: Xác minh quyền `logs:DescribeLogGroups`, `logs:GetLogEvents`. <br> - **ValidationException**: Kiểm tra dữ liệu đầu vào. <br> - **SES error**: Xác minh email SES. |

> **Mẹo thực tiễn**: Kích hoạt **POST /students** qua giao diện web để tạo log mới. Sử dụng Logs Insights để lọc lỗi nhanh. Đặt CloudWatch Alarms cho Duration hoặc Memory Used nếu cần giám sát hiệu suất.

---

## Kết Luận

CloudWatch Logs cho phép theo dõi hoạt động của Lambda `insertStudentData`, xác minh lưu dữ liệu vào `studentData` và gửi email SES. Logs giúp gỡ lỗi và tối ưu hóa hệ thống serverless, tích hợp với API `student` và giao diện web qua CloudFront.

> **Bước tiếp theo**: Tối ưu hóa hệ thống hoặc thiết lập CloudWatch Alarms để giám sát tự động!