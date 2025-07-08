---
title: "Dọn Dẹp Tài Nguyên"
date: 2023-10-25
weight: 12
chapter: false
pre: "<b>12. </b>"
---

> **Mục tiêu**: Dọn dẹp tất cả tài nguyên AWS của hệ thống serverless (S3, Lambda, API Gateway, CloudFront, DynamoDB, SES, EventBridge, IAM) để tránh chi phí không cần thiết sau khi hoàn thành triển khai và kiểm tra website quản lý thông tin sinh viên. Đảm bảo xóa sạch các tài nguyên liên quan, bao gồm bảng DynamoDB, Lambda functions, S3 Buckets, API Gateway, CloudFront Distribution, SES identities, IAM Roles, và EventBridge Rule.

---

## Tổng Quan về Dọn Dẹp Tài Nguyên

- **Mục đích**: Xóa các tài nguyên đã tạo trong các mục 2.4, 3.1–3.3, 4.1–4.9, 5, 6.1–6.5, 7.1–7.3, 8.1–8.2 để đảm bảo tài khoản AWS không phát sinh chi phí sau khi hoàn thành bài lab.  
- **Tài nguyên cần xóa**:  
  - **DynamoDB**: Bảng `studentData` (mục 3).  
  - **Lambda**: Hàm `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail` (mục 3.1–3.3, 8.1).  
  - **S3**: Buckets `student-management-website-2025`, `student-backup-20250706` (mục 2.4, 6.1–6.5).  
  - **API Gateway**: API `student`, stage `prod`, `StudentApiKey`, `StudentUsagePlan` (mục 4.1–4.9).  
  - **CloudFront**: Distribution `StudentWebsiteDistribution` (mục 7.1–7.3).  
  - **SES**: Verified identities (`no-reply@studentapp.com`, `admin@studentapp.com`, `nguyentribaothang@gmail.com`) (mục 3).  
  - **IAM**: Roles `LambdaGetStudentRole`, `LambdaInsertStudentRole`, `DynamoDBBackupRoleStudent` (mục 6.5).  
  - **EventBridge**: Rule `DailyDynamoDBBackup` (mục 8.2).  

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Đảm bảo bạn đã hoàn thành các mục 2.4, 3.1–3.3, 4.1–4.9, 5, 6.1–6.5, 7.1–7.3, 8.1–8.2 và kiểm tra kết quả (mục 9). Tài khoản AWS cần quyền:  
- `dynamodb:DeleteTable`  
- `lambda:DeleteFunction`  
- `s3:DeleteBucket`, `s3:DeleteObject`  
- `apigateway:DELETE`  
- `cloudfront:UpdateDistribution`, `cloudfront:DeleteDistribution`  
- `ses:DeleteIdentity`  
- `iam:DeleteRole`  
- `events:DeleteRule`, `events:RemoveTargets`  
Vùng AWS: `us-east-1`.  
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Xóa Bảng DynamoDB studentData**  
   - Trong **AWS Management Console**, tìm **DynamoDB > Tables > studentData**.  
   - Nhấn **Actions > Delete table**.  
   - Nhập `Confirm`, nhấn **Delete**.  
   - **Kết quả mong đợi**: Bảng `studentData` không còn trong danh sách.  
   - **Xử lý lỗi**: Nếu bảng đang được sử dụng (VD: bởi Lambda), kiểm tra log CloudWatch (mục 10) và đảm bảo không có hàm nào truy cập.  
     ![Xóa bảng DynamoDB.](/images/12-cleaning-up-resources/cleaning-up-resources-01.png)  
     *Hình 1: Xóa bảng DynamoDB.*

2. **Xóa Lambda Functions**  
   - Trong **AWS Management Console**, tìm **Lambda > Functions**.  
   - Chọn từng hàm: `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`.  
   - Nhấn **Actions > Delete function**, nhập `delete`, nhấn **Delete**.  
   - **Kết quả mong đợi**: Các hàm không còn trong danh sách.  
   - **Xử lý lỗi**: Nếu hàm bị gắn với trigger (VD: API Gateway), xóa trigger trước (bước 4).  
     ![Xóa Lambda functions.](/images/12-cleaning-up-resources/cleaning-up-resources-02.png)  
     *Hình 5: Xóa Lambda functions.*

3. **Xóa S3 Buckets**  
   - Trong **AWS Management Console**, tìm **S3 > Buckets**.  
   - Đối với mỗi bucket (`student-management-website-2025`, `student-backup-20250706`):  
     - Chọn bucket, nhấn **Empty**, nhập `permanently delete`, nhấn **Empty**.  
     - Sau khi xóa hết objects, chọn bucket, nhấn **Delete**, nhập tên bucket, nhấn **Delete bucket**.  
   - **Kết quả mong đợi**: Buckets không còn trong danh sách.  
   - **Xử lý lỗi**: Nếu bucket không xóa được, kiểm tra quyền `s3:DeleteBucket`, `s3:DeleteObject` hoặc objects còn lại.  
     ![Xóa S3 buckets.](/images/12-cleaning-up-resources/cleaning-up-resources-03.png)  
     *Hình 6: Xóa S3 buckets.*

4. **Xóa API Gateway student**  
   - Trong **AWS Management Console**, tìm **API Gateway > APIs > student**.  
   - Nhấn **API Actions > Delete API**, nhập `confirm`, nhấn **Delete**.  
   - **Kết quả mong đợi**: API `student` (bao gồm stage `prod`, `StudentApiKey`, `StudentUsagePlan`) không còn trong danh sách.  
   - **Xử lý lỗi**: Nếu API đang được sử dụng, kiểm tra CloudFront hoặc log CloudWatch (mục 10).  
     ![Xóa API Gateway.](/images/12-cleaning-up-resources/cleaning-up-resources-04.png)  
     *Hình 7: Xóa API Gateway.*  
     ![Xác nhận xóa API.](/images/12-cleaning-up-resources/cleaning-up-resources-05.png)  
     *Hình 8: Xác nhận xóa API.*  
     ![API đã xóa.](/images/12-cleaning-up-resources/cleaning-up-resources-06.png)  
     *Hình 9: API đã xóa.*
     ![Xóa API Gateway.](/images/12-cleaning-up-resources/cleaning-up-resources-07.png)  
     *Hình 7: Xóa API Gateway.*  
     ![Xác nhận xóa API.](/images/12-cleaning-up-resources/cleaning-up-resources-08.png)  
     *Hình 8: Xác nhận xóa API.*  
     ![API đã xóa.](/images/12-cleaning-up-resources/cleaning-up-resources-09.png)  
     *Hình 9: API đã xóa.*

5. **Xóa CloudFront Distribution**  
   - Trong **AWS Management Console**, tìm **CloudFront > Distributions > StudentWebsiteDistribution**.  
   - Nhấn **Disable**, chờ trạng thái thành **Disabled** (5–15 phút).  
   - Chọn **Distribution**, nhấn **Delete**, xác nhận **Yes, Delete**.  
   - **Kết quả mong đợi**: Distribution không còn trong danh sách.  
   - **Xử lý lỗi**: Nếu không thể vô hiệu hóa, kiểm tra quyền `cloudfront:UpdateDistribution`, `cloudfront:DeleteDistribution`.  
     ![Xóa CloudFront Distribution.](/images/12-cleaning-up-resources/cleaning-up-resources-10.png)  
     *Hình 10: Xóa CloudFront Distribution.*

6. **Xóa SES Verified Identities**  
   - Trong **AWS Management Console**, tìm **SES > Verified identities**.  
   - Chọn email: `nguyentribaothang@gmail.com`, `no-reply@studentapp.com`, `admin@studentapp.com` (nếu có), nhấn **Delete identity**.  
   - **Kết quả mong đợi**: Các email không còn trong danh sách.  
   - **Xử lý lỗi**: Nếu email đang được sử dụng, kiểm tra Lambda `insertStudentData` hoặc `DynamoDBBackup` đã xóa (bước 2).  
     ![Xóa SES identities.](/images/12-cleaning-up-resources/cleaning-up-resources-11.png)  
     *Hình 11: Xóa SES identities.*

7. **Xóa IAM Roles**  
   - Trong **AWS Management Console**, tìm **IAM > Roles**.  
   - Chọn từng role: `LambdaGetStudentRole`, `LambdaInsertStudentRole`, `DynamoDBBackupRoleStudent`, nhấn **Delete role**, xác nhận.  
   - **Kết quả mong đợi**: Các role không còn trong danh sách.  
   - **Xử lý lỗi**: Nếu role đang được sử dụng, đảm bảo Lambda functions và API Gateway đã xóa.  
     ![Xóa IAM roles.](/images/12-cleaning-up-resources/cleaning-up-resources-12.png)  
     *Hình 12: Xóa IAM roles.*

8. **Xóa EventBridge Rule**  
   - Trong **AWS Management Console**, tìm **EventBridge > Rules > DailyDynamoDBBackup**.  
   - Nhấn **Delete**, xác nhận trong pop-up.  
   - **Kết quả mong đợi**: Rule `DailyDynamoDBBackup` không còn trong danh sách.  
   - **Xử lý lỗi**: Nếu rule không xóa được, kiểm tra quyền `events:DeleteRule`, `events:RemoveTargets` hoặc đảm bảo Lambda `BackupDynamoDBAndSendEmail` đã xóa.  
     ![Xóa EventBridge Rule.](/images/12-cleaning-up-resources/cleaning-up-resources-13.png)  
     *Hình 13: Xóa EventBridge Rule.*

---

## Kết Luận

Tất cả tài nguyên AWS (`studentData`, Lambda functions, S3 Buckets, API `student`, CloudFront `StudentWebsiteDistribution`, SES identities, IAM Roles, EventBridge Rule) đã được xóa, đảm bảo không phát sinh chi phí. Hệ thống serverless được dọn dẹp hoàn toàn.

> **Bước tiếp theo**: Kiểm tra AWS Billing Dashboard để xác minh không còn chi phí hoặc bắt đầu triển khai dự án mới!