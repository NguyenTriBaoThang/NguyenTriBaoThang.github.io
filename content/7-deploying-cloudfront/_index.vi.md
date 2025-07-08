---
title: "Triển Khai CloudFront để Tăng Tốc Website"
date: 2023-10-25
weight: 7
chapter: false
pre: "<b>7. </b>"
---

> **Mục tiêu**: Triển khai Amazon CloudFront, một dịch vụ CDN (Content Delivery Network), để tăng tốc độ tải và bảo mật giao diện web tĩnh lưu trữ trên S3 Bucket `student-management-website-2025` (mục 6). CloudFront sẽ:  
> - Phân phối nội dung từ S3 qua HTTPS, cải thiện hiệu suất với các edge locations toàn cầu.  
> - Phục vụ tệp `index.html` (mục 6.2) làm trang mặc định thông qua **Default Root Object**.  
> - Làm mới nội dung cache khi cần cập nhật giao diện.  
> CloudFront tích hợp với API `student` (stage `prod`, mục 4.8) để hỗ trợ các endpoint **GET /students**, **POST /students**, và **POST /backup**, sử dụng `StudentApiKey` (mục 4.2) với CORS được cấu hình (mục 4.7) để gọi từ domain CloudFront.

---

## Tổng Quan về CloudFront trong Ứng Dụng

- **Vai trò của CloudFront**:  
  - Cung cấp HTTPS cho giao diện web (S3 chỉ hỗ trợ HTTP qua **Static Website Hosting**, mục 6.3).  
  - Tăng tốc độ tải bằng cách lưu cache nội dung tại các edge locations gần người dùng.  
  - Tích hợp với S3 Bucket `student-management-website-2025` (mục 6.1–6.4) để phục vụ các tệp `index.html`, `styles.css`, `scripts.js`.  
  - Hỗ trợ bảo mật API Key bằng CloudFront Functions (khuyến nghị) để thêm header `x-api-key` mà không nhúng trong `scripts.js`.  
- **Tích hợp với hệ thống**:  
  - Giao diện web (phân phối qua CloudFront) gọi API `student` (mục 4.8) với **Invoke URL** (VD: https://abc123.execute-api.us-east-1.amazonaws.com/prod) và `StudentApiKey`.  
  - Các chức năng:  
    - **POST /students**: Lưu bản ghi vào DynamoDB `studentData` và gửi email qua SES.  
    - **GET /students**: Hiển thị dữ liệu trong bảng.  
    - **POST /backup**: Tạo tệp backup trong S3 Bucket `student-backup-20250706` (mục 6.5) và gửi email thông báo qua SES.  
  - CORS được cấu hình (mục 4.7) để hỗ trợ yêu cầu từ domain CloudFront (VD: https://d12345678.cloudfront.net).  

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành mục 6.1 (tạo bucket `student-management-website-2025`), mục 6.2 (tải lên `index.html`, `styles.css`, `scripts.js`), mục 6.3 (bật **Static Website Hosting**), mục 6.4 (cấu hình **Bucket Policy**), mục 6.5 (cấu hình bucket `student-backup-20250706`), mục 5 (xây dựng giao diện web), mục 4.1 (tạo API `student`), mục 4.2 (tạo API Key `StudentApiKey`), mục 4.3 (tạo Usage Plan `StudentUsagePlan`), mục 4.4 (tạo phương thức **GET /students**), mục 4.5 (tạo phương thức **POST /students**), mục 4.6 (tạo resource `/backup` và phương thức **POST /backup**), mục 4.7 (kích hoạt CORS), mục 4.8 (triển khai API lên stage `prod`), mục 4.9 (gắn `StudentApiKey` vào `StudentUsagePlan`), mục 3 (tạo các hàm Lambda, bảng DynamoDB `studentData`, bucket `student-backup-20250706`, SES). Đảm bảo tài khoản AWS có quyền `cloudfront:CreateDistribution`, `cloudfront:CreateInvalidation`, và vùng AWS là `us-east-1` cho các dịch vụ liên quan.
{{% /notice %}}

---

## Các Bước Cấu Hình

Dưới đây là các bước cụ thể để triển khai CloudFront:

| **Bước** | **Nội Dung** | **Mô Tả** |
|----------|--------------|-----------|
| 7.1 | [Tạo CloudFront Distribution](/7-deploying-cloudfront/7.1-creating-a-cloudfront-distribution/) | Tạo một CloudFront distribution để phân phối nội dung từ bucket `student-management-website-2025` qua HTTPS. |
| 7.2 | [Cấu hình Default Root Object](/7-deploying-cloudfront/7.2-configuring-default-root-object/) | Đặt `index.html` làm **Default Root Object** để phục vụ trang chính khi truy cập domain CloudFront. |
| 7.3 | [Tạo Invalidation để làm mới nội dung cache](/7-deploying-cloudfront/7.3-creating-cloudfront-invalidation/) | Tạo invalidation để làm mới cache CloudFront, đảm bảo nội dung mới nhất từ S3 được phục vụ. |

> **Lưu ý**: Thực hiện các bước theo thứ tự để đảm bảo CloudFront được cấu hình chính xác. Mỗi bước được hướng dẫn chi tiết trong các tài liệu tương ứng.

---

## Kết Luận

Hoàn thành các bước cấu hình này, bạn sẽ có:  
- Một CloudFront distribution phân phối nội dung từ bucket `student-management-website-2025` qua HTTPS, cải thiện tốc độ và bảo mật.  
- Giao diện web tích hợp với API `student` (stage `prod`), hỗ trợ các chức năng **GET /students**, **POST /students**, và **POST /backup**.  
- Hệ thống sẵn sàng để kiểm tra và triển khai sản xuất.

> **Sẵn sàng tiếp tục?**  
> Chuyển đến [Tạo CloudFront Distribution](/7-deploying-cloudfront/7.1-creating-a-cloudfront-distribution/) để bắt đầu triển khai CloudFront!