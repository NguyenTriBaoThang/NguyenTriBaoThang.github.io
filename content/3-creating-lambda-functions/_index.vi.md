---
title: "Tạo Lambda Functions"
date: 2025-07-09
weight: 3
chapter: false
pre: "<b> 3. </b>"
---

> **Mục tiêu**: Tạo và cấu hình ba hàm Lambda trong AWS để hỗ trợ các chức năng chính của hệ thống quản lý thông tin sinh viên:  
> - `getStudentData`: Truy xuất toàn bộ dữ liệu sinh viên từ bảng DynamoDB `studentData`.  
> - `insertStudentData`: Lưu thông tin sinh viên vào bảng DynamoDB và gửi email xác nhận qua SES.  
> - `BackupDynamoDBAndSendEmail`: Sao lưu dữ liệu từ bảng DynamoDB vào S3 và gửi email thông báo chứa link tải tệp backup.  

Mỗi hàm sẽ được tạo thông qua AWS Management Console, sử dụng ngôn ngữ lập trình **Python 3.12** (hoặc phiên bản mới nhất được hỗ trợ), gán IAM Role tương ứng (đã tạo ở các mục 2.1, 2.2, 2.3) và cấu hình để tích hợp với các dịch vụ AWS khác (DynamoDB, SES, S3). Các bước dưới đây đảm bảo người học có thể triển khai các hàm một cách dễ dàng, đồng thời tối ưu hóa hiệu suất và bảo mật.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành các bước chuẩn bị ở mục 2 (IAM Roles, bảng DynamoDB, SES) trước khi tạo các hàm Lambda. Đảm bảo tài khoản AWS đã sẵn sàng.
{{% /notice %}}

---

## Các Bước Cấu Hình

Dưới đây là các bước cụ thể để cấu hình các hàm Lambda:

| **Bước** | **Nội Dung** | **Mô Tả** |
|----------|--------------|-----------|
| 3.1 | [Tạo hàm getStudentData](./3.1-create-the-getstudentdata-function/) | Tạo hàm Lambda để truy xuất toàn bộ dữ liệu sinh viên từ bảng DynamoDB `studentData` sử dụng thao tác Scan. |
| 3.2 | [Tạo hàm insertStudentData](./3.2-create-the-insertstudentdata-function/) | Tạo hàm Lambda để lưu thông tin sinh viên vào bảng DynamoDB `studentData` và gửi email xác nhận qua SES. |
| 3.3 | [Tạo hàm BackupDynamoDBAndSendEmail](./3.3-create-the-backupdynamodbandsendemail-function/) | Tạo hàm Lambda để sao lưu dữ liệu từ bảng DynamoDB `studentData` vào S3 và gửi email thông báo chứa pre-signed URL. |

> **Lưu ý**: Thực hiện các bước theo thứ tự để đảm bảo các hàm được cấu hình chính xác. Mỗi bước sẽ được hướng dẫn chi tiết trong các tài liệu tương ứng.

---

## Kết Luận

Hoàn thành các bước cấu hình này, bạn sẽ có:  
- Hàm **getStudentData** để truy xuất dữ liệu sinh viên.  
- Hàm **insertStudentData** để lưu trữ và gửi email xác nhận.  
- Hàm **BackupDynamoDBAndSendEmail** để sao lưu dữ liệu và gửi thông báo.  

> **Sẵn sàng tiếp tục?**  
> Chuyển đến [Tạo hàm getStudentData](./3.1-create-the-getstudentdata-function/) để bắt đầu cấu hình hàm Lambda đầu tiên!