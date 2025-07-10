---
title: "Cấu Hình S3 Bucket để Lưu Trữ và Phục Vụ Website"
date: 2025-07-09
weight: 6
chapter: false
pre: "<b>6. </b>"
---

> **Mục tiêu**: Cấu hình hai Amazon S3 Bucket để:  
> - **Lưu trữ và phục vụ giao diện web**: Tạo bucket `student-management-website-2025` để lưu trữ các tệp tĩnh (`index.html`, `styles.css`, `scripts.js` từ mục 5), bật tính năng **Static Website Hosting**, và cấu hình quyền truy cập công khai để phục vụ giao diện qua CloudFront (mục 7).  
> - **Sao lưu dữ liệu**: Cấu hình bucket `student-backup-20250706` (tạo ở mục 2.4) để lưu trữ tệp backup từ endpoint **POST /backup** (mục 4.6), đảm bảo hàm Lambda `BackupDynamoDBAndSendEmail` có quyền ghi vào bucket.  
> Cấu hình này tích hợp với API `student` (stage `prod`, mục 4.8) và đảm bảo giao diện web (sử dụng Tailwind CSS) hoạt động mượt mà với các endpoint **GET /students**, **POST /students**, và **POST /backup**.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành mục 2.4 (tạo bucket `student-backup-20250706`), mục 3.3 (tạo hàm Lambda `BackupDynamoDBAndSendEmail` với vai trò `DynamoDBBackupRole`), mục 4.1 (tạo API `student`), mục 4.2 (tạo API Key `StudentApiKey`), mục 4.3 (tạo Usage Plan `StudentUsagePlan`), mục 4.4 (tạo phương thức **GET /students**), mục 4.5 (tạo phương thức **POST /students**), mục 4.6 (tạo resource `/backup` và phương thức **POST /backup**), mục 4.7 (kích hoạt CORS), mục 4.8 (triển khai API lên stage `prod`), mục 4.9 (gắn `StudentApiKey` vào `StudentUsagePlan` và liên kết với API `student` stage `prod`), và mục 5 (xây dựng giao diện web với `index.html`, `styles.css`, `scripts.js`). Đảm bảo tài khoản AWS có quyền truy cập S3 (`s3:CreateBucket`, `s3:PutBucketPolicy`, `s3:PutBucketWebsite`), Lambda, API Gateway, và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Các Bước Cấu Hình

Dưới đây là các bước cụ thể để cấu hình S3 Bucket:

| **Bước** | **Nội Dung** | **Mô Tả** |
|----------|--------------|-----------|
| 6.1 | [Khởi tạo S3 Bucket mới](/6-configuring-s3-buckets/6.1-creating-a-new-s3-bucket/) | Tạo bucket `student-management-website-2025` để lưu trữ các tệp tĩnh (`index.html`, `styles.css`, `scripts.js`). |
| 6.2 | [Tải tài nguyên giao diện lên S3 (HTML/CSS/JS)](/6-configuring-s3-buckets/6.2-uploading-static-assets-to-s3/) | Tải các tệp tĩnh từ mục 5 lên bucket `student-management-website-2025`. |
| 6.3 | [Bật tính năng Static Website Hosting](/6-configuring-s3-buckets/6.3-enabling-static-website-hosting/) | Kích hoạt **Static Website Hosting** trong bucket `student-management-website-2025` để phục vụ giao diện web. |
| 6.4 | [Cấu hình Bucket Policy để cho phép truy cập công khai](/6-configuring-s3-buckets/6.4-setting-bucket-policy-for-public-access/) | Cập nhật **Bucket Policy** của `student-management-website-2025` để cho phép CloudFront truy xuất nội dung (`s3:GetObject`). |
| 6.5 | [Cập nhật Bucket Policy để hỗ trợ sao lưu dữ liệu (Backup)](/6-configuring-s3-buckets/6.5-updating-bucket-policy-to-support-backup/) | Cập nhật **Bucket Policy** của `student-backup-20250706` để cho phép hàm Lambda `BackupDynamoDBAndSendEmail` ghi tệp (`s3:PutObject`). |

> **Lưu ý**: Thực hiện các bước theo thứ tự để đảm bảo cấu hình S3 Bucket chính xác. Mỗi bước được hướng dẫn chi tiết trong các tài liệu tương ứng.

---

## Kết Luận

Hoàn thành các bước cấu hình này, bạn sẽ có:  
- Bucket `student-management-website-2025` lưu trữ và phục vụ giao diện web tĩnh, sẵn sàng tích hợp với CloudFront.  
- Bucket `student-backup-20250706` hỗ trợ lưu trữ tệp backup từ endpoint **POST /backup**, tích hợp với hàm Lambda `BackupDynamoDBAndSendEmail`.  
- Hệ thống tích hợp đầy đủ với API `student` (stage `prod`) và giao diện web sử dụng Tailwind CSS.

> **Sẵn sàng tiếp tục?**  
> Chuyển đến [Khởi tạo S3 Bucket mới](/6-configuring-s3-buckets/6.1-creating-a-new-s3-bucket/) để bắt đầu cấu hình bucket `student-management-website-2025`!