---
title: "Các Bước Chuẩn Bị"
date: 2023-10-25
weight: 2
chapter: false
pre: "<b>2. </b>"
---



> **Mục tiêu**: Thiết lập môi trường cần thiết để triển khai ứng dụng serverless quản lý thông tin sinh viên, bao gồm tài khoản AWS, các IAM Role, bảng DynamoDB, và dịch vụ SES.

Để bắt đầu workshop **Triển khai Website Serverless Quản Lý Thông Tin Sinh Viên với AWS**, bạn cần chuẩn bị các thành phần cơ bản để đảm bảo tích hợp mượt mà với các dịch vụ AWS như Lambda, DynamoDB, API Gateway, S3, CloudFront, và SES.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần có một **tài khoản AWS** để thực hiện các bước trong workshop. Nếu chưa có, hãy tạo tài khoản trước khi tiếp tục.
{{% /notice %}}

Để tìm hiểu cách tạo tài khoản AWS, tham khảo hướng dẫn chi tiết tại:  
- [Hướng dẫn tạo tài khoản AWS](https://000001.awsstudygroup.com/)

---

## Các Bước Chuẩn Bị

Dưới đây là các bước cụ thể để chuẩn bị môi trường cho ứng dụng serverless:

| **Bước** | **Nội Dung** | **Mô Tả** |
|----------|--------------|-----------|
| 2.1 | [Tạo IAM Role cho Lambda Get](/2-preparation-steps/2.1-create-iam-role-for-lambda-get/) | Tạo vai trò IAM cho hàm Lambda xử lý truy xuất dữ liệu sinh viên từ DynamoDB, đảm bảo quyền truy cập an toàn và tối thiểu. |
| 2.2 | [Tạo IAM Role cho Lambda Post](/2-preparation-steps/2.2-create-iam-role-for-lambda-post/) | Tạo vai trò IAM cho hàm Lambda xử lý lưu trữ dữ liệu sinh viên vào DynamoDB, tuân thủ nguyên tắc quyền tối thiểu. |
| 2.3 | [Tạo IAM Role cho DynamoDB Backup](/2-preparation-steps/2.3-create-iam-role-for-dynamodb-backup/) | Tạo vai trò IAM cho hàm Lambda thực hiện sao lưu dữ liệu từ DynamoDB vào S3, bao gồm quyền ghi vào S3 và gửi email qua SES. |
| 2.4 | [Tạo bảng trong DynamoDB](/2-preparation-steps/2.4-createtable-in-dynamodb/) | Thiết lập bảng `studentData` với khóa chính `studentid` (String) để lưu trữ thông tin sinh viên (Mã sinh viên, Họ tên, Lớp, Ngày sinh, Email). |
| 2.5 | [Cấu hình SES](/2-preparation-steps/2.5-configureses/) | Cấu hình AWS SES để gửi email xác nhận khi lưu dữ liệu và thông báo sao lưu với pre-signed URL. |

> **Lưu ý**: Thực hiện các bước theo thứ tự để đảm bảo môi trường được thiết lập chính xác. Mỗi bước sẽ được hướng dẫn chi tiết trong các tài liệu tương ứng.

---

## Kết Luận

Hoàn thành các bước chuẩn bị này, bạn sẽ có:  
- Một **tài khoản AWS** sẵn sàng để triển khai ứng dụng.  
- Các **IAM Role** được cấu hình để đảm bảo bảo mật và quyền truy cập tối thiểu.  
- Bảng **studentData** trong DynamoDB để lưu trữ dữ liệu sinh viên.  
- Dịch vụ **SES** được thiết lập để gửi thông báo qua email.  

> **Sẵn sàng tiếp tục?**  
> Chuyển đến [Tạo IAM Role cho Lambda Get](/2-preparation-steps/2.1-create-iam-role-for-lambda-get/) để bắt đầu thiết lập vai trò IAM cho hàm Lambda đầu tiên!