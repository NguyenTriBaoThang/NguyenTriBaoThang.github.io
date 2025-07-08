---
title: "Thiết Lập Backup Hệ Thống Tự Động"
date: 2023-10-25
weight: 8
chapter: false
pre: "<b>8. </b>"
---

> **Mục tiêu**: Thiết lập hệ thống backup tự động cho bảng DynamoDB `studentData` bằng cách chỉnh sửa Lambda function `BackupDynamoDBAndSendEmail` (tích hợp với endpoint **POST /backup**, mục 4.8) và tạo Amazon EventBridge Rule để kích hoạt backup định kỳ. Backup sẽ lưu dữ liệu vào S3 Bucket `student-backup-20250706` (mục 6.5) và gửi email thông báo qua Amazon SES. Hệ thống đảm bảo:  
> - Tự động hóa quy trình backup để giảm thiểu can thiệp thủ công.  
> - Tích hợp với giao diện web (phân phối qua CloudFront, mục 7.1–7.3) và API `student` (stage `prod`, mục 4.8).  
> - Bảo mật với `StudentApiKey` (mục 4.2) và vai trò IAM `DynamoDBBackupRole` (mục 6.5).

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành mục 7.1–7.3 (tạo và cấu hình CloudFront `StudentWebsiteDistribution`), mục 6.1–6.5 (cấu hình S3 Buckets `student-management-website-2025` và `student-backup-20250706`), mục 5 (xây dựng giao diện web), mục 4.1–4.9 (tạo và triển khai API `student`, `StudentApiKey`, `StudentUsagePlan`, endpoint **GET /students**, **POST /students**, **POST /backup**, CORS, stage `prod`), mục 3.3 (tạo Lambda function `BackupDynamoDBAndSendEmail` với vai trò `DynamoDBBackupRole`), mục 3 (tạo bảng DynamoDB `studentData`, SES email xác minh). Đảm bảo tài khoản AWS có quyền `lambda:UpdateFunctionConfiguration`, `events:PutRule`, `events:PutTargets`, `iam:PassRole`, và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Các Bước Cấu Hình

Dưới đây là các bước cụ thể để thiết lập backup tự động:

| **Bước** | **Nội Dung** | **Mô Tả** |
|----------|--------------|-----------|
| 8.1 | [Chỉnh sửa cấu hình trong Lambda Backup](/8-automatic-backup/8.1-configuring-lambda-backup/) | Cập nhật Lambda function `BackupDynamoDBAndSendEmail` để hỗ trợ kích hoạt từ EventBridge, đảm bảo lưu dữ liệu từ DynamoDB `studentData` vào S3 `student-backup-20250706` và gửi email qua SES. |
| 8.2 | [Tạo EventBridge Rule để tự động hóa Backup](/8-automatic-backup/8.2-creating-eventbridge-rule/) | Tạo Amazon EventBridge Rule `StudentDataBackupRule` để kích hoạt Lambda function `BackupDynamoDBAndSendEmail` định kỳ (VD: hàng ngày). |

> **Lưu ý**: Thực hiện các bước theo thứ tự để đảm bảo cấu hình backup tự động chính xác. Mỗi bước được hướng dẫn chi tiết trong các tài liệu tương ứng.

---

## Kết Luận

Hoàn thành các bước cấu hình này, bạn sẽ có:  
- Lambda function `BackupDynamoDBAndSendEmail` được cập nhật để hỗ trợ cả API Gateway và EventBridge.  
- EventBridge Rule `StudentDataBackupRule` kích hoạt backup định kỳ, lưu dữ liệu từ DynamoDB `studentData` vào S3 `student-backup-20250706` với thông báo qua SES.  
- Hệ thống tích hợp đầy đủ với API `student` (stage `prod`) và giao diện web qua CloudFront `StudentWebsiteDistribution`.

> **Sẵn sàng tiếp tục?**  
> Chuyển đến [Chỉnh sửa cấu hình trong Lambda Backup](/8-automatic-backup/8.1-configuring-lambda-backup/) để bắt đầu cấu hình Lambda function!