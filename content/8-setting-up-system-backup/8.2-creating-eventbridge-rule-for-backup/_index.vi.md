---
title: "Tạo EventBridge Rule để Tự Động Hóa Backup"
date: 2023-10-25
weight: 2
chapter: false
pre: "<b>8.2. </b>"
---

> **Mục tiêu**: Tạo Amazon EventBridge Rule `DailyDynamoDBBackup` để kích hoạt Lambda function `BackupDynamoDBAndSendEmail` (tạo ở mục 3.3, cấu hình ở mục 8.1) theo lịch trình định kỳ, tự động backup dữ liệu từ bảng DynamoDB `studentData` vào S3 Bucket `student-backup-20250706` (mục 6.5) và gửi email thông báo qua Amazon SES. Lịch trình chạy hàng ngày lúc 07:00 AM +07 (00:00 UTC) với cửa sổ thời gian linh hoạt 5 phút, đảm bảo tích hợp với hệ thống serverless và giao diện web qua CloudFront.

---

## Tổng Quan về EventBridge Rule

- **Vai trò của EventBridge Rule**:  
  - Amazon EventBridge lập lịch kích hoạt Lambda function `BackupDynamoDBAndSendEmail` định kỳ (hàng ngày lúc 07:00 AM +07, tức 00:00 UTC).  
  - Đảm bảo backup tự động, lưu tệp JSON vào S3 `student-backup-20250706`, và gửi email thông báo qua SES, giảm can thiệp thủ công.  
  - Sử dụng biểu thức Cron `0 0 * * ? *` và Flexible Time Window 5 phút để tối ưu hóa hiệu suất.  
- **Tích hợp với hệ thống**:  
  - Giao diện web (CloudFront `StudentWebsiteDistribution`, mục 7.1–7.3) từ S3 `student-management-website-2025` (mục 6.1–6.4) gọi API `student` (stage `prod`, mục 4.8) với **Invoke URL** (VD: `https://abc123.execute-api.us-east-1.amazonaws.com/prod`) và `StudentApiKey` (mục 4.2).  
  - Các chức năng:  
    - **POST /students**: Lưu bản ghi vào DynamoDB `studentData` và gửi email qua SES.  
    - **GET /students**: Hiển thị dữ liệu trong bảng.  
    - **POST /backup**: Tạo tệp JSON trong `student-backup-20250706` và gửi email thông báo.  
  - CORS cấu hình (mục 4.7) hỗ trợ yêu cầu từ domain CloudFront (VD: `https://d12345678.cloudfront.net`).  
  - Vai trò IAM `DynamoDBBackupRoleStudent` (mục 6.5) cấp quyền cho Lambda truy cập DynamoDB, S3, SES.  
  - EventBridge sử dụng vai trò `Amazon_EventBridge_Scheduler_LAMBDA_7e5e967abf` để kích hoạt Lambda.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành:  
- Mục 2.4: Tạo S3 Bucket `student-backup-20250706`.  
- Mục 3.3: Tạo Lambda function `BackupDynamoDBAndSendEmail` với vai trò `DynamoDBBackupRoleStudent`.  
- Mục 4.1–4.9: Tạo API `student`, `StudentApiKey`, `StudentUsagePlan`, các phương thức **GET /students**, **POST /students**, **POST /backup**, kích hoạt CORS, triển khai stage `prod`.  
- Mục 5: Xây dựng giao diện web (`index.html`, `styles.css`, `scripts.js`).  
- Mục 6.1–6.5: Tạo và cấu hình S3 Bucket `student-management-website-2025` và `student-backup-20250706`.  
- Mục 7.1–7.3: Tạo CloudFront `StudentWebsiteDistribution`.  
- Mục 8.1: Cấu hình Lambda `BackupDynamoDBAndSendEmail` với Memory 128 MB, Ephemeral Storage 512 MB, vai trò `DynamoDBBackupRoleStudent`, và biến môi trường `S3_BUCKET_NAME`, `SENDER_EMAIL`, `RECIPIENT_EMAIL`.  
Đảm bảo tài khoản AWS có quyền `events:PutRule`, `events:PutTargets`, `iam:CreateRole`, `iam:PassRole`, và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console và Amazon EventBridge**  
   - Đăng nhập **[AWS Management Console](https://console.aws.amazon.com)**.  
   - Tìm **EventBridge**, chọn **Amazon EventBridge**.  
   - Xác minh vùng AWS: `us-east-1` để đồng bộ với DynamoDB `studentData`, S3 (`student-management-website-2025`, `student-backup-20250706`), Lambda, API Gateway, SES, CloudFront.  
     ![Giao diện AWS Console với thanh tìm kiếm EventBridge.](/images/8-setting-up-system-backup/8.2-creating-eventbridge-rule-for-backup/creating-eventbridge-rule-for-backup-01.png)  
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm EventBridge.*

2. **Chọn Rules**  
   - Trong **EventBridge**, chọn **Rules** từ menu bên trái.  
   - Nhấn **Create rule**.  
     ![Nút Create rule trong giao diện EventBridge.](/images/8-setting-up-system-backup/8.2-creating-eventbridge-rule-for-backup/creating-eventbridge-rule-for-backup-02.png)  
     *Hình 2: Nút Create rule trong giao diện EventBridge.*

3. **Cấu Hình Rule**  
   - Trong **Create rule**:  
     - **Name**: `DailyDynamoDBBackup` (phản ánh mục đích backup hàng ngày).  
     - **Description**: _Backup DynamoDB and send email daily at 7:00 AM +07._  
     - **Event bus**: Chọn **default**.  
     - **Rule type**: Chọn **Schedule**.  
   - Nhấn **Continue in EventBridge Scheduler**.  
     ![Cấu hình tên và mô tả rule.](/images/8-setting-up-system-backup/8.2-creating-eventbridge-rule-for-backup/creating-eventbridge-rule-for-backup-03.png)  
     *Hình 3: Cấu hình tên và mô tả rule.*

4. **Thiết Lập Lịch Trình**  
   - Trong **Schedule pattern**:  
     - **Occurrence**: Chọn **Recurring schedule**.  
     - **Schedule type**: Chọn **Cron-based schedule**.  
     - **Cron expression**: Nhập `0 0 * * ? *` (chạy 00:00 UTC, tức 07:00 AM +07, mỗi ngày).  
       - **Giải thích**: `0 0 * * ? *` = phút 0, giờ 0, mọi ngày/tháng, bất kỳ ngày tuần, mọi năm.  
       - **Tùy chọn**: Hàng tuần vào Chủ nhật 07:00 AM +07, dùng `0 0 * * SUN`.  
   - Kiểm tra múi giờ hệ thống để tránh nhầm lẫn.  
   - Nhấn **Next**.  
     ![Cấu hình lịch trình Cron.](/images/8-setting-up-system-backup/8.2-creating-eventbridge-rule-for-backup/creating-eventbridge-rule-for-backup-04.png)  
     *Hình 4: Cấu hình lịch trình Cron.*

5. **Cấu Hình Flexible Time Window**  
   - Trong **Flexible time window**:  
     - Chọn **Enable flexible time window**.  
     - **Maximum time window**: 5 minutes (AWS tối ưu hóa thời gian chạy trong 00:00–00:05 UTC).  
       - **Lý do**: Phù hợp cho backup nhỏ như `studentData`, không ảnh hưởng tính đúng giờ.  
   - Nhấn **Next**.  
     ![Cấu hình Flexible Time Window.](/images/8-setting-up-system-backup/8.2-creating-eventbridge-rule-for-backup/creating-eventbridge-rule-for-backup-05.png)  
     *Hình 5: Cấu hình Flexible Time Window.*

6. **Chọn Target API**  
   - Trong **Target(s)**:  
     - **Target type**: Chọn **AWS service**.  
     - **Select a target**: Chọn **Lambda function**.  
       - **Lý do**: `BackupDynamoDBAndSendEmail` là đích thực thi backup.  
     - Nhấn **Next**.  
     ![Chọn Target API.](/images/8-setting-up-system-backup/8.2-creating-eventbridge-rule-for-backup/creating-eventbridge-rule-for-backup-06.png)  
     *Hình 6: Chọn Target API.*

7. **Chọn Lambda Function**  
   - Trong **Function**, chọn `BackupDynamoDBAndSendEmail`.  
   - **Xử lý lỗi**: Nếu hàm không xuất hiện, kiểm tra hàm tồn tại trong `us-east-1` và quyền `lambda:ListFunctions`.  
     ![Chọn Lambda function.](/images/8-setting-up-system-backup/8.2-creating-eventbridge-rule-for-backup/creating-eventbridge-rule-for-backup-07.png)  
     *Hình 7: Chọn Lambda function.*

8. **Cấu Hình Execution Role**  
   - Trong **Permissions**:  
     - Chọn **Create new role for this schedule**.  
     - **Role name**: `Amazon_EventBridge_Scheduler_LAMBDA_7e5e967abf`.  
       - **Lý do**: Vai trò cho phép EventBridge kích hoạt Lambda.  
     - Xác minh quyền:  
       ```json
       {
           "Version": "2012-10-17",
           "Statement": [
               {
                   "Effect": "Allow",
                   "Action": "lambda:InvokeFunction",
                   "Resource": "arn:aws:lambda:us-east-1:<AWS_ACCOUNT_ID>:function:BackupDynamoDBAndSendEmail",
                   "Principal": {"Service": "scheduler.amazonaws.com"}
               }
           ]
       }
       ```  
       Thay `<AWS_ACCOUNT_ID>` bằng ID tài khoản AWS.  
   - Nhấn **Next**.  
     ![Cấu hình Execution Role.](/images/8-setting-up-system-backup/8.2-creating-eventbridge-rule-for-backup/creating-eventbridge-rule-for-backup-09.png)  
     *Hình 8: Cấu hình Execution Role.*

9. **Xem Lại và Tạo Schedule**  
   - Xem lại cấu hình:  
     - **Name**: `DailyDynamoDBBackup`.  
     - **Description**: _Backup DynamoDB and send email daily at 7:00 AM +07._  
     - **Schedule**: `cron(0 0 * * ? *)`.  
     - **Flexible time window**: 5 minutes.  
     - **Target**: `BackupDynamoDBAndSendEmail`.  
   - Nhấn **Create Schedule**.  
   - Kết quả: Thông báo _"Your schedule DailyDynamoDBBackup is being created"_.  
     ![Xem lại và tạo Schedule.](/images/8-setting-up-system-backup/8.2-creating-eventbridge-rule-for-backup/creating-eventbridge-rule-for-backup-10.png)  
     *Hình 9: Xem lại và tạo Schedule.*

10. **Kiểm Tra Rule**  
    - Trong **EventBridge > Rules**, xác minh `DailyDynamoDBBackup` với:  
      - **Status**: Enabled.  
      - **Schedule**: `cron(0 0 * * ? *)`.  
      - **Target**: `BackupDynamoDBAndSendEmail`.  
    - Test hoạt động:  
      - Tạm chỉnh lịch chạy mỗi 5 phút: Trong **EventBridge > Rules**, chọn `DailyDynamoDBBackup` > **Edit** > **Schedule pattern**, nhập `*/5 * * * ? *`, nhấn **Update rule**.  
      - Sau 5 phút (hoặc 00:00 UTC ngày tiếp theo):  
        - **S3**: Kiểm tra `student-backup-20250706` cho tệp JSON (VD: `students-backup-20250708T0700.json`).  
        - **SES**: Xác minh email tại `admin@studentapp.com` với subject `Backup Completed: students-backup-20250708T0700.json` và body `Backup saved to s3://student-backup-20250706/students-backup-20250708T0700.json`.  
        - **CloudWatch Logs**: Trong **CloudWatch > Log groups > /aws/lambda/BackupDynamoDBAndSendEmail**, kiểm tra log:  
          ```log
          fields @timestamp, @message
          | filter @message like /Backup completed/
          | sort @timestamp desc
          ```  
    - **Xử lý lỗi**:  
      - **Rule không kích hoạt**:  
        - Kiểm tra trạng thái rule là **Enabled**.  
        - Xác minh vai trò `Amazon_EventBridge_Scheduler_LAMBDA_7e5e967abf` có quyền `lambda:InvokeFunction`.  
      - **Lambda lỗi**:  
        - Kiểm tra log trong **CloudWatch > Log groups > /aws/lambda/BackupDynamoDBAndSendEmail**.  
        - Đảm bảo `DynamoDBBackupRoleStudent` có quyền `dynamodb:Scan`, `s3:PutObject`, `ses:SendEmail` (mục 8.1).  
      - **Tệp không xuất hiện trong S3**:  
        - Xác minh bucket `student-backup-20250706` và **Bucket Policy** (mục 6.5):  
          ```json
          {
              "Version": "2012-10-17",
              "Statement": [
                  {
                      "Sid": "AllowLambdaPutObject",
                      "Effect": "Allow",
                      "Principal": {"AWS": "arn:aws:iam::<AWS_ACCOUNT_ID>:role/DynamoDBBackupRoleStudent"},
                      "Action": "s3:PutObject",
                      "Resource": "arn:aws:s3:::student-backup-20250706/*"
                  }
              ]
          }
          ```  
          Thay `<AWS_ACCOUNT_ID>` bằng ID tài khoản AWS.  
      - **Email không gửi**:  
        - Xác minh email `no-reply@studentapp.com`, `admin@studentapp.com` trong SES (mục 3).  
        - Kiểm tra quyền `ses:SendEmail` trong `DynamoDBBackupRoleStudent`.  
    - Sau khi test, khôi phục lịch trình về `0 0 * * ? *`.  
      ![Thông báo trạng thái tạo rule.](/images/8-setting-up-system-backup/8.2-creating-eventbridge-rule-for-backup/creating-eventbridge-rule-for-backup-11.png)  
      *Hình 10: Thông báo trạng thái tạo rule.*

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Bảo mật** | - Đảm bảo vai trò `Amazon_EventBridge_Scheduler_LAMBDA_7e5e967abf` chỉ cấp quyền `lambda:InvokeFunction` cho `BackupDynamoDBAndSendEmail`. <br> - Không nhúng `StudentApiKey` trong `scripts.js`. Sử dụng CloudFront Functions: <br> ```javascript <br> function handler(event) { <br> var request = event.request; <br> request.headers['x-api-key'] = { value: 'xxxxxxxxxxxxxxxxxxxx' }; <br> return request; <br> } <br> ``` |
| **Tối ưu hóa** | - Bật CloudWatch Logs cho Lambda (mục 8.1). <br> - Kiểm tra rule bằng AWS CLI: <br> ```bash <br> aws events describe-rule --name DailyDynamoDBBackup <br> ``` |
| **Tích hợp** | - Xác minh CORS trong API Gateway (mục 4.7): `Access-Control-Allow-Origin: https://d12345678.cloudfront.net`. <br> - Test endpoint **POST /backup** qua CloudFront URL để đảm bảo tích hợp với giao diện web. |
| **Kiểm tra tích hợp** | - Truy cập CloudFront URL (`https://d12345678.cloudfront.net`): <br> - **POST /students**: Lưu bản ghi, gửi email SES. <br> - **GET /students**: Hiển thị bảng. <br> - **POST /backup**: Tạo tệp trong `student-backup-20250706`, gửi email. <br> - Dùng **Developer Tools > Network** để kiểm tra yêu cầu API. |
| **Xử lý lỗi** | - **Rule không chạy**: Kiểm tra trạng thái **Enabled**, quyền `events:PutRule`, `events:PutTargets`. <br> - **Lambda lỗi**: Kiểm tra log CloudWatch, quyền `DynamoDBBackupRoleStudent`. <br> - **Tệp không xuất hiện**: Xác minh bucket policy `student-backup-20250706`. <br> - **Email không gửi**: Xác minh SES email và quyền `ses:SendEmail`. |

> **Mẹo thực tiễn**: Test rule ngay bằng lịch trình `*/5 * * * ? *`, sau đó khôi phục về `0 0 * * ? *`. Kiểm tra CloudWatch Logs và S3 để xác minh backup. Cấu hình S3 Lifecycle Rule cho `student-backup-20250706` để quản lý tệp cũ.

---

## Kết Luận

Rule `DailyDynamoDBBackup` được tạo để kích hoạt Lambda `BackupDynamoDBAndSendEmail` hàng ngày lúc 07:00 AM +07, lưu dữ liệu từ DynamoDB `studentData` vào S3 `student-backup-20250706` và gửi email qua SES. Hệ thống tích hợp với API `student` và giao diện web qua CloudFront.

> **Bước tiếp theo**: Theo dõi backup trong S3 và email SES, tối ưu hóa nếu cần!