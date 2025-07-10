---
title: "Chỉnh Sửa Cấu Hình trong Lambda Backup"
date: 2025-07-09
weight: 1
chapter: false
pre: "<b>8.1. </b>"
---

> **Mục tiêu**: Cập nhật cấu hình cho Lambda function `BackupDynamoDBAndSendEmail` (tạo ở mục 3.3, tích hợp với endpoint **POST /backup**, mục 4.6) để đảm bảo hoạt động hiệu quả khi backup dữ liệu từ bảng DynamoDB `studentData` vào S3 Bucket `student-backup-20250706` (mục 6.5) và gửi email thông báo qua Amazon SES. Cấu hình bao gồm Memory, Ephemeral Storage, Execution Role, và Environment Variables để tối ưu hiệu suất và tích hợp với hệ thống serverless.

---

## Tổng Quan về Lambda Backup

- **Vai trò của Lambda `BackupDynamoDBAndSendEmail`**:  
  - Xử lý endpoint **POST /backup** trong API `student` (stage `prod`, mục 4.8), đọc dữ liệu từ DynamoDB `studentData`, lưu tệp JSON vào S3 `student-backup-20250706`, và gửi email thông báo qua SES.  
  - Cập nhật để hỗ trợ kích hoạt từ API Gateway và Amazon EventBridge (mục 8.2) cho backup thủ công (qua giao diện web) và tự động (qua lịch trình).  
- **Tích hợp với hệ thống**:  
  - Giao diện web (phân phối qua CloudFront `StudentWebsiteDistribution`, mục 7.1–7.3) từ S3 Bucket `student-management-website-2025` (mục 6.1–6.4) gọi API `student` với **Invoke URL** (VD: `https://abc123.execute-api.us-east-1.amazonaws.com/prod`) và `StudentApiKey` (mục 4.2).  
  - Các chức năng:  
    - **POST /students**: Lưu bản ghi vào DynamoDB `studentData` và gửi email qua SES.  
    - **GET /students**: Hiển thị dữ liệu trong bảng.  
    - **POST /backup**: Tạo tệp JSON trong `student-backup-20250706` và gửi email thông báo.  
  - CORS được cấu hình (mục 4.7) để hỗ trợ yêu cầu từ domain CloudFront (VD: `https://d12345678.cloudfront.net`).  
  - Vai trò IAM `DynamoDBBackupRole` (mục 6.5) cấp quyền truy cập DynamoDB, S3, và SES.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành các mục sau:  
- Mục 2.4: Tạo S3 Bucket `student-backup-20250706`.  
- Mục 3.3: Tạo Lambda function `BackupDynamoDBAndSendEmail` với vai trò `DynamoDBBackupRole`.  
- Mục 4.1–4.9: Tạo và cấu hình API `student`, bao gồm `StudentApiKey`, `StudentUsagePlan`, các phương thức **GET /students**, **POST /students**, **POST /backup**, kích hoạt CORS, và triển khai stage `prod`.  
- Mục 5: Xây dựng giao diện web với `index.html`, `styles.css`, `scripts.js`.  
- Mục 6.1–6.5: Tạo và cấu hình S3 Bucket `student-management-website-2025` và `student-backup-20250706`.  
- Mục 7.1–7.3: Tạo và cấu hình CloudFront `StudentWebsiteDistribution`.  
Đảm bảo tài khoản AWS có quyền `lambda:UpdateFunctionConfiguration`, `lambda:GetFunction`, `s3:PutObject`, `dynamodb:Scan`, `ses:SendEmail`, và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console và Lambda**  
   - Đăng nhập **[AWS Management Console](https://console.aws.amazon.com)**.  
   - Trong thanh tìm kiếm, nhập **Lambda** và chọn **AWS Lambda**.  
   - Xác minh vùng AWS: `us-east-1` để đồng bộ với DynamoDB `studentData`, S3 (`student-management-website-2025`, `student-backup-20250706`), API Gateway, SES, và CloudFront.  
     ![Giao diện AWS Console với thanh tìm kiếm Lambda.](/images/8-setting-up-system-backup/8.1-modifying-backup-lambda-configuration/modifying-backup-lambda-configuration-01.png)
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm Lambda.*

2. **Chọn Danh Sách Functions**  
   - Trong **Lambda > Functions**, xem danh sách các Lambda function.  
   - Kiểm tra: Đảm bảo hàm `BackupDynamoDBAndSendEmail` (mục 3.3) xuất hiện.  
   - **Xử lý lỗi**: Nếu không thấy, xác minh tên hàm và quyền `lambda:GetFunction`:  
     ```json
     {
         "Version": "2012-10-17",
         "Statement": [
             {
                 "Effect": "Allow",
                 "Action": "lambda:GetFunction",
                 "Resource": "arn:aws:lambda:us-east-1:<AWS_ACCOUNT_ID>:function:BackupDynamoDBAndSendEmail"
             }
         ]
     }
     ```  
     Thay `<AWS_ACCOUNT_ID>` bằng ID tài khoản AWS.  
     ![Danh sách Lambda Functions.](/images/8-setting-up-system-backup/8.1-modifying-backup-lambda-configuration/modifying-backup-lambda-configuration-02.png)
     *Hình 2: Danh sách Lambda Functions.*

3. **Chọn Lambda Function Backup**  
   - Nhấp vào `BackupDynamoDBAndSendEmail` để vào giao diện chi tiết.  
   - **Nhận diện**: Hàm gắn với endpoint **POST /backup** (mục 4.6) và vai trò `DynamoDBBackupRole` (mục 6.5).  
     ![Giao diện chi tiết của Lambda function.](/images/8-setting-up-system-backup/8.1-modifying-backup-lambda-configuration/modifying-backup-lambda-configuration-03.png)
     *Hình 3: Giao diện chi tiết của Lambda function.*

4. **Truy Cập Tab Configuration**  
   - Trong giao diện chi tiết, chọn tab **Configuration** (bên cạnh **Code**, **Test**).  

5. **Cập Nhật General Configuration**  
   - Trong **Configuration > General configuration**, nhấn **Edit**.  
   - Cấu hình:  
     - **Memory**: 128 MB (đủ cho đọc DynamoDB, ghi S3, gửi email SES; tăng nếu cần nhưng cân nhắc chi phí).  
     - **Ephemeral Storage**: 512 MB (mặc định, đủ cho dữ liệu tạm).  
     - **Execution Role**: Chọn **Use an existing role**, chọn `DynamoDBBackupRole`.  
       - Xác minh quyền:  
         ```json
         {
             "Version": "2012-10-17",
             "Statement": [
                 {
                     "Effect": "Allow",
                     "Action": [
                         "dynamodb:Scan",
                         "s3:PutObject",
                         "ses:SendEmail"
                     ],
                     "Resource": [
                         "arn:aws:dynamodb:us-east-1:<AWS_ACCOUNT_ID>:table/studentData",
                         "arn:aws:s3:::student-backup-20250706/*",
                         "arn:aws:ses:us-east-1:<AWS_ACCOUNT_ID>:identity/*"
                     ]
                 }
             ]
         }
         ```  
         Thay `<AWS_ACCOUNT_ID>` bằng ID tài khoản AWS.  
   - Nhấn **Save**.  
   - **Xử lý lỗi**:  
     - Vai trò không xuất hiện: Kiểm tra `DynamoDBBackupRole` (mục 6.5) và quyền `iam:PassRole`.  
     - Lỗi quyền: Đảm bảo ARN của `studentData`, `student-backup-20250706`, SES identity đúng.  
     ![Cập nhật General configuration.](/images/8-setting-up-system-backup/8.1-modifying-backup-lambda-configuration/modifying-backup-lambda-configuration-04.png)
     *Hình 4: Cập nhật General configuration.*

6. **Lưu Cấu Hình**  
   - Nhấn **Save**.  
   - Kết quả: Thông báo _"Successfully updated function configuration"_. Memory (128 MB), Ephemeral Storage (512 MB), và Execution Role (`DynamoDBBackupRole`) được cập nhật.  
   - **Xử lý lỗi**:  
     - **AccessDenied**: Kiểm tra quyền `lambda:UpdateFunctionConfiguration`:  
       ```json
       {
           "Version": "2012-10-17",
           "Statement": [
               {
                   "Effect": "Allow",
                   "Action": "lambda:UpdateFunctionConfiguration",
                   "Resource": "arn:aws:lambda:us-east-1:<AWS_ACCOUNT_ID>:function:BackupDynamoDBAndSendEmail"
               }
           ]
       }
       ```  
     - Cấu hình không lưu: Kiểm tra giá trị nhập và vai trò `DynamoDBBackupRole`.  
     ![Thông báo lưu cấu hình thành công.](/images/8-setting-up-system-backup/8.1-modifying-backup-lambda-configuration/modifying-backup-lambda-configuration-06.png)
     *Hình 5: Thông báo lưu cấu hình thành công.*

7. **Tạo Environment Variables**  
   - Trong **Configuration > Environment variables**, nhấn **Edit**.  
   - Thêm biến:  
     - **Key**: `S3_BUCKET_NAME`, **Value**: `student-backup-20250706` (bucket đích cho backup JSON).  
     - **Key**: `SENDER_EMAIL`, **Value**: `no-reply@studentapp.com` (SES verified email).  
     - **Key**: `RECIPIENT_EMAIL`, **Value**: `admin@studentapp.com` (SES verified email).  
   - Nhấn **Save**.  
   - **Lý do**: Các biến môi trường giúp mã nguồn Lambda tham chiếu bucket và email động, tránh hardcode.  
   - **Xử lý lỗi**:  
     - Lỗi lưu: Kiểm tra quyền `lambda:UpdateFunctionConfiguration`.  
     - Bucket không tồn tại: Xác minh `student-backup-20250706` (mục 2.4).  
     - Email không hợp lệ: Xác minh `no-reply@studentapp.com` và `admin@studentapp.com` trong SES (mục 3).  
     ![Thêm Environment variables.](/images/8-setting-up-system-backup/8.1-modifying-backup-lambda-configuration/modifying-backup-lambda-configuration-07.png)
     *Hình 6: Thêm Environment variables.*

8. **Kiểm Tra Cấu Hình Lambda**  
   - Trong **Test**, tạo sự kiện test với nội dung `{}` (mô phỏng EventBridge).  
   - Nhấn **Test**.  
   - Kết quả mong đợi:  
     - Tệp JSON (VD: `students-backup-20250708T1236.json`) xuất hiện trong S3 `student-backup-20250706`.  
     - Email gửi đến `admin@studentapp.com` với subject `Backup Completed: students-backup-20250708T1236.json` và body `Backup saved to s3://student-backup-20250706/students-backup-20250708T1236.json`.  
   - **Xử lý lỗi**:  
     - **AccessDenied**: Kiểm tra quyền `s3:PutObject`, `dynamodb:Scan`, `ses:SendEmail` trong `DynamoDBBackupRole`.  
     - **No items in DynamoDB**: Gọi **POST /students** (mục 4.5) để thêm dữ liệu vào `studentData`.  
     - **SES error**: Xác minh email `no-reply@studentapp.com`, `admin@studentapp.com` trong SES (mục 3).  
     - **Environment variable not found**: Kiểm tra `S3_BUCKET_NAME`, `SENDER_EMAIL`, `RECIPIENT_EMAIL` trong **Environment variables**.  
     ![Kết quả test Lambda.](/images/8-setting-up-system-backup/8.1-modifying-backup-lambda-configuration/modifying-backup-lambda-configuration-08.png)
     *Hình 7: Kết quả test Lambda.*

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Bảo mật** | - Tránh nhúng `StudentApiKey` trong `scripts.js`. Sử dụng CloudFront Functions để thêm header `x-api-key`: <br> ```javascript <br> function handler(event) { <br> var request = event.request; <br> request.headers['x-api-key'] = { value: 'xxxxxxxxxxxxxxxxxxxx' }; <br> return request; <br> } <br> ``` <br> - Xác minh email SES (`no-reply@studentapp.com`, `admin@studentapp.com`) trước khi gửi. |
| **Tối ưu hóa** | - Bật CloudWatch Logs cho Lambda: Trong **Configuration > Monitoring and operations tools**, chọn **Enable CloudWatch Logs**. <br> - Sử dụng AWS CLI để kiểm tra cấu hình: <br> ```bash <br> aws lambda get-function-configuration --function-name BackupDynamoDBAndSendEmail <br> ``` |
| **Tích hợp** | - CORS: Đảm bảo `Access-Control-Allow-Origin: https://d12345678.cloudfront.net` trong API Gateway (mục 4.7). <br> - Xác minh endpoint **POST /students**, **GET /students**, **POST /backup** hoạt động với `StudentApiKey`. |
| **Kiểm tra tích hợp** | - Truy cập CloudFront URL (`https://d12345678.cloudfront.net`) và kiểm tra: <br> - **POST /students**: Lưu bản ghi, gửi email SES. <br> - **GET /students**: Hiển thị bảng. <br> - **POST /backup**: Tạo tệp trong `student-backup-20250706`, gửi email. <br> - Sử dụng **Developer Tools > Network** để kiểm tra yêu cầu API. |
| **Xử lý lỗi** | - **AccessDenied**: Kiểm tra quyền trong `DynamoDBBackupRole` và bucket policy của `student-backup-20250706`. <br> - **SES error**: Xác minh email SES. <br> - **No data**: Thêm dữ liệu vào `studentData` qua **POST /students**. <br> - **Environment variable error**: Kiểm tra biến môi trường trong **Configuration**. |

> **Mẹo thực tiễn**: Test Lambda sau mỗi cập nhật bằng sự kiện `{}`. Kiểm tra CloudWatch Logs để gỡ lỗi. Chuẩn bị cho mục 8.2 bằng cách xác minh hàm hoạt động đúng với endpoint **POST /backup**.

---

## Kết Luận

Lambda function `BackupDynamoDBAndSendEmail` đã được cấu hình với Memory (128 MB), Ephemeral Storage (512 MB), vai trò `DynamoDBBackupRole`, và biến môi trường (`S3_BUCKET_NAME`, `SENDER_EMAIL`, `RECIPIENT_EMAIL`). Hàm sẵn sàng backup dữ liệu từ DynamoDB `studentData` vào S3 `student-backup-20250706` và gửi email qua SES, tích hợp với API `student` và giao diện web.

> **Bước tiếp theo**: Chuyển đến [Tạo EventBridge Rule để tự động hóa Backup](/8-automatic-backup/8.2-creating-eventbridge-rule/) để kích hoạt backup định kỳ!