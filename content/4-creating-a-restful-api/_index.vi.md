---
title: "Cấu hình RESTful API Bảo Mật bằng API Key"
date: 2023-10-25
weight: 4
chapter: false
pre: "<b>4. </b>"
---

> **Mục tiêu**: Tạo một RESTful API bằng AWS API Gateway để tích hợp với các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`), cho phép giao diện web (chạy trên CloudFront) truy xuất, lưu trữ, và sao lưu dữ liệu sinh viên. API sẽ được bảo mật bằng API Key, sử dụng Usage Plan để giới hạn truy cập, và kích hoạt CORS để hỗ trợ giao tiếp với giao diện web. API sẽ được triển khai trên một stage (ví dụ: `prod`) và liên kết với API Key để đảm bảo chỉ các yêu cầu hợp lệ được xử lý.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành các bước ở mục 3 (tạo các hàm Lambda `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, SES email xác minh). Đảm bảo tài khoản AWS đã sẵn sàng và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Các Bước Cấu Hình

Dưới đây là các bước cụ thể để cấu hình RESTful API:

| **Bước** | **Nội Dung** | **Mô Tả** |
|----------|--------------|-----------|
| 4.1 | [Tạo REST API mới trên API Gateway](/4-creating-a-restful-api/4.1-creating-a-rest-api/) | Tạo một REST API mới trong AWS API Gateway để tích hợp với các hàm Lambda. |
| 4.2 | [Tạo API Key để bảo vệ truy cập](/4-creating-a-restful-api/4.2-creating-an-api-key/) | Tạo API Key để bảo mật các yêu cầu truy cập API từ giao diện web. |
| 4.3 | [Thiết lập Usage Plan (Kế hoạch sử dụng)](/4-creating-a-restful-api/4.3-creating-a-usage-plan/) | Thiết lập Usage Plan để giới hạn số lượng yêu cầu API và quản lý truy cập. |
| 4.4 | [Tạo phương thức GET để truy xuất dữ liệu](/4-creating-a-restful-api/4.4-creating-a-get-method/) | Tạo phương thức GET cho endpoint `/students` để gọi hàm `getStudentData` và truy xuất dữ liệu sinh viên. |
| 4.5 | [Tạo phương thức POST để lưu dữ liệu](/4-creating-a-restful-api/4.5-creating-a-post-method/) | Tạo phương thức POST cho endpoint `/students` để gọi hàm `insertStudentData` và lưu thông tin sinh viên. |
| 4.6 | [Tạo Resource & Method cho tính năng Backup dữ liệu](/4-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/) | Tạo resource và phương thức POST cho endpoint `/backup` để gọi hàm `BackupDynamoDBAndSendEmail`. |
| 4.7 | [Kích hoạt CORS để hỗ trợ frontend truy cập](/4-creating-a-restful-api/4.7-enabling-cors/) | Kích hoạt CORS để hỗ trợ các yêu cầu cross-origin từ giao diện web trên CloudFront. |
| 4.8 | [Triển khai (Deploy) API lên một Stage cụ thể](/4-creating-a-restful-api/4.8-deploying-the-api/) | Triển khai API lên một stage (ví dụ: `prod`) để sử dụng trong môi trường production. |
| 4.9 | [Gắn API Key vào Usage Plan & liên kết với REST API và Stage](/4-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/) | Liên kết API Key với Usage Plan và stage để đảm bảo chỉ các yêu cầu hợp lệ được xử lý. |

> **Lưu ý**: Thực hiện các bước theo thứ tự để đảm bảo API được cấu hình chính xác. Mỗi bước sẽ được hướng dẫn chi tiết trong các tài liệu tương ứng.

---

## Kết Luận

Hoàn thành các bước cấu hình này, bạn sẽ có:  
- RESTful API tích hợp với các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`).  
- API được bảo mật bằng API Key và Usage Plan.  
- Hỗ trợ CORS cho giao diện web trên CloudFront.  

> **Sẵn sàng tiếp tục?**  
> Chuyển đến [Tạo REST API mới trên API Gateway](/4-creating-a-restful-api/4.1-creating-a-rest-api/) để bắt đầu cấu hình API đầu tiên!