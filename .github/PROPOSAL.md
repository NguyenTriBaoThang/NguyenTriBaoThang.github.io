# Workshop: Triển Khai Website Serverless Quản Lý Thông Tin Sinh Viên với AWS 🚀

![AWS Serverless](https://img.shields.io/badge/AWS-Serverless-orange?logo=amazonaws) ![Duration](https://img.shields.io/badge/Duration-8%20Hours-blue) ![Level](https://img.shields.io/badge/Level-Intermediate-green)

Chào mừng bạn đến với workshop thực hành **Triển Khai Website Serverless Quản Lý Thông Tin Sinh Viên với AWS**! Đây là chương trình đào tạo chuyên sâu giúp bạn xây dựng một ứng dụng web serverless trên Amazon Web Services (AWS), từ giao diện tĩnh đến backend tích hợp sao lưu tự động và giám sát hiệu suất.

---

## Thông Tin Sinh Viên Thực Tập 👨‍🎓

### Thành Viên 1
- **Họ và Tên**: Nguyễn Tri Bão Thắng  
- **Trường**: Đại Học Công nghệ TP.HCM (HUTECH)  
- **MSSV**: 2180601452  
- **Gmail**: [nguyentribaothang@gmail.com](mailto:nguyentribaothang@gmail.com)  
- **GitHub**: [NguyenTriBaoThang](https://github.com/NguyenTriBaoThang)  
- **Link Workshop**: [https://nguyentribaothang.github.io/](https://nguyentribaothang.github.io/)

### Thành Viên 2
- **Họ và Tên**: Võ Thành Trung  
- **Trường**: Đại Học Công nghệ TP.HCM (HUTECH)  
- **MSSV**: 2180603167  
- **Gmail**: [vothanhtrung9379@gmail.com](mailto:vothanhtrung9379@gmail.com)  
- **GitHub**: [NguyenTriBaoThang](https://github.com/NguyenTriBaoThang)  
- **Link Workshop**: [https://nguyentribaothang.github.io/](https://nguyentribaothang.github.io/)

---

## Executive Summary

Workshop kéo dài **8 giờ**, hướng dẫn xây dựng ứng dụng web serverless quản lý thông tin sinh viên trên AWS, sử dụng **S3**, **CloudFront**, **API Gateway**, **Lambda**, **DynamoDB**, **SES**, và **EventBridge**. Với **12 phần chính**, từ giới thiệu serverless đến dọn dẹp tài nguyên, chương trình đảm bảo trải nghiệm học tập thực tiễn.

**Đối tượng**: Lập trình viên, sinh viên CNTT, chuyên gia IT.  
**Mục tiêu**: Trang bị kỹ năng serverless, áp dụng thực tiễn về **bảo mật**, **hiệu suất**, và **tối ưu chi phí**.  
**Phù hợp**: Tổ chức giáo dục, trung tâm đào tạo, doanh nghiệp nâng cao năng lực công nghệ đám mây.

---

## Problem Statement

Nhu cầu kỹ năng phát triển ứng dụng serverless tăng mạnh, đặc biệt trong giáo dục và quản lý dữ liệu. Tuy nhiên, lập trình viên và sinh viên tại Việt Nam gặp thách thức:
- Thiếu kinh nghiệm áp dụng **kiến trúc serverless** để xây dựng ứng dụng tiết kiệm chi phí.
- Khó khăn tích hợp các dịch vụ AWS như **S3**, **API Gateway**, **Lambda**.
- Chưa đảm bảo **bảo mật**, **hiệu suất**, và **tối ưu chi phí**.
- Không quen quản lý tài nguyên để tránh chi phí dư thừa.

Workshop cung cấp chương trình thực hành, hướng dẫn xây dựng ứng dụng serverless quản lý sinh viên, tập trung vào bảo mật và tối ưu chi phí.

---

## Solution Architecture

Hệ thống sử dụng **kiến trúc serverless** trên AWS:
- **Frontend**: Giao diện tĩnh (`index.html`, `styles.css` với Tailwind CSS, `scripts.js`) lưu trữ trong S3 bucket `student-management-website-2025`, phân phối qua CloudFront `StudentWebsiteDistribution`.
- **Backend**: API REST `student` (stage `prod`) trên API Gateway, tích hợp Lambda functions (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`), lưu trữ trong DynamoDB `studentData`.
- **Sao Lưu & Thông Báo**: Lambda `BackupDynamoDBAndSendEmail` sao lưu dữ liệu vào S3 `student-backup-20250706`, kích hoạt bởi EventBridge Rule `DailyDynamoDBBackup`, gửi email qua SES (`no-reply@studentapp.com`).
- **Bảo Mật**: API key (`StudentApiKey`), CORS, Origin Access Identity (OAI), CloudFront Functions.
- **Giám Sát**: CloudWatch Logs theo dõi Lambda và API Gateway.
- **Quản Lý Chi Phí**: Quy trình dọn dẹp tài nguyên (Phần 12).

---

## Technical Implementation

Workshop gồm **12 phần**, sử dụng công cụ:
- **AWS Management Console**
- **AWS CLI**
- **Visual Studio Code** (HTML/CSS/JS)
- **Tailwind CSS**
- **Postman** (kiểm tra API)
- **Node.js** (quản lý thư viện JS)
- **CloudWatch Logs Insights**

### Phần 1: Giới Thiệu
- **Mô Tả**: Tổng quan serverless, lợi ích, mục tiêu học tập.
- **Hoạt Động**: Trình bày kiến trúc, giới thiệu AWS services (S3, CloudFront, API Gateway, Lambda, DynamoDB, SES, EventBridge).
- **Công Cụ**: AWS Management Console, trình duyệt web.
- **Kết Quả**: Hiểu mục tiêu và kiến trúc hệ thống.

### Phần 2: Các Bước Chuẩn Bị
- **Mô Tả**: Thiết lập môi trường AWS.
- **Hoạt Động**: Tạo tài khoản AWS (`us-east-1`), cài AWS CLI, tạo S3 bucket `student-backup-20250706`.
- **Công Cụ**: AWS Management Console, AWS CLI, Visual Studio Code.
- **Kết Quả**: Môi trường AWS sẵn sàng.

### Phần 3: Cấu Hình Lambda Functions
- **Mô Tả**: Tạo Lambda xử lý logic backend.
- **Hoạt Động**: Tạo DynamoDB `studentData`, Lambda functions (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`), gắn IAM roles (`LambdaGetStudentRole`, `LambdaInsertStudentRole`, `DynamoDBBackupRoleStudent`).
- **Công Cụ**: AWS Management Console, AWS CLI, Visual Studio Code.
- **Kết Quả**: Backend xử lý dữ liệu sinh viên.

### Phần 4: Tạo RESTful API
- **Mô Tả**: Cấu hình API Gateway.
- **Hoạt Động**: Tạo API `student` (stage `prod`) với GET/POST `/students`, POST `/backup`, cấu hình `StudentApiKey`, `StudentUsagePlan`, kích hoạt CORS.
- **Công Cụ**: AWS Management Console, Postman.
- **Kết Quả**: API REST bảo mật, tích hợp Lambda.

### Phần 5: Viết Giao Diện cho Website
- **Mô Tả**: Thiết kế giao diện tĩnh.
- **Hoạt Động**: Tạo `index.html`, `styles.css` (Tailwind CSS), `scripts.js` với form nhập liệu, bảng sinh viên, nút Lưu/Xem/Sao lưu.
- **Công Cụ**: Visual Studio Code, Tailwind CSS, Node.js.
- **Kết Quả**: Giao diện web tích hợp API.

### Phần 6: Cấu Hình S3 Bucket
- **Mô Tả**: Tạo S3 bucket lưu trữ.
- **Hoạt Động**: Tạo bucket `student-management-website-2025`, bật Static Website Hosting, cấu hình Bucket Policy với OAI.
- **Công Cụ**: AWS Management Console, AWS CLI.
- **Kết Quả**: S3 lưu trữ giao diện và sao lưu.

### Phần 7: Triển Khai CloudFront
- **Mô Tả**: Phân phối nội dung qua CloudFront.
- **Hoạt Động**: Tạo CloudFront `StudentWebsiteDistribution`, đặt `index.html` làm Default Root Object, tạo invalidation.
- **Công Cụ**: AWS Management Console, AWS CLI.
- **Kết Quả**: Giao diện phân phối qua CloudFront.

### Phần 8: Thiết Lập Backup Hệ Thống
- **Mô Tả**: Tự động hóa sao lưu.
- **Hoạt Động**: Cập nhật Lambda `BackupDynamoDBAndSendEmail` (128 MB RAM, 512 MB lưu trữ), tạo EventBridge Rule `DailyDynamoDBBackup` (07:00 AM +07), gửi email qua SES.
- **Công Cụ**: AWS Management Console, AWS CLI, Visual Studio Code.
- **Kết Quả**: Sao lưu tự động, email thông báo.

### Phần 9: Kiểm Tra Kết Quả
- **Mô Tả**: Xác minh hệ thống.
- **Hoạt Động**: Kiểm tra giao diện qua CloudFront URL, endpoint API, DynamoDB, S3, SES.
- **Công Cụ**: AWS Management Console, Postman, trình duyệt web.
- **Kết Quả**: Hệ thống hoạt động đầy đủ.

### Phần 10: Xem Logs Hoạt Động Bằng CloudWatch
- **Mô Tả**: Phân tích log hệ thống.
- **Hoạt Động**: Phân tích CloudWatch Logs cho Lambda, sử dụng Logs Insights (VD: `fields @message | filter @message like /ERROR/`).
- **Công Cụ**: AWS Management Console, CloudWatch Logs Insights.
- **Kết Quả**: Phát hiện và khắc phục lỗi.

### Phần 11: Video Demo Tham Khảo
- **Mô Tả**: Xem video minh họa.
- **Hoạt Động**: Xem video demo 35 phút (cấu hình AWS, giao diện, backend).
- **Công Cụ**: Trình duyệt web, phần mềm xem video.
- **Kết Quả**: Hiểu trực quan quy trình.

### Phần 12: Dọn Dẹp Tài Nguyên
- **Mô Tả**: Xóa tài nguyên tránh chi phí.
- **Hoạt Động**: Xóa DynamoDB, Lambda, S3, API Gateway, CloudFront, SES, IAM, EventBridge, kiểm tra qua AWS CLI.
- **Công Cụ**: AWS Management Console, AWS CLI.
- **Kết Quả**: Tài khoản AWS sạch, không chi phí dư.

---

## Timeline & Milestones

Workshop kéo dài **8 giờ**, chia thành 2 buổi:

### Buổi 1 (4 giờ)
- **0:00–0:30**: Phần 1 (Giới thiệu).
- **0:30–1:30**: Phần 2–3 (Chuẩn bị, Lambda).
- **1:30–2:30**: Phần 4–5 (API, giao diện).
- **2:30–3:30**: Phần 6–7 (S3, CloudFront).
- **3:30–4:00**: Q&A, nghỉ giải lao.

### Buổi 2 (4 giờ)
- **0:00–1:30**: Phần 8–9 (Sao lưu, kiểm tra).
- **1:30–2:30**: Phần 10–11 (CloudWatch, video).
- **2:30–3:30**: Phần 12 (Dọn dẹp).
- **3:30–4:00**: Tổng kết, đánh giá.

**Cột Mốc**:
- **Cuối Buổi 1**: Giao diện và API hoạt động, tích hợp CloudFront.
- **Cuối Buổi 2**: Hệ thống hoàn chỉnh, tài nguyên dọn dẹp.
- **Sau Workshop**: Phân phối tài liệu, mã nguồn, video demo.

---

## Budget Estimation

Ước tính chi phí **các dịch vụ AWS** cho 20–30 người, sử dụng **AWS Free Tier** và dọn dẹp tài nguyên (Phần 12). Giá dựa trên vùng `us-east-1` (09/07/2025, [AWS Pricing](https://aws.amazon.com/pricing/)).

| Dịch Vụ AWS            | Sử Dụng                                                                 | Free Tier                              | Chi Phí          |
|------------------------|-------------------------------------------------------------------------|----------------------------------------|------------------|
| **Amazon S3**          | Lưu trữ `student-management-website-2025` (~1 MB), `student-backup-20250706` (~1 MB) | 5 GB lưu trữ, 20.000 GET, 2.000 PUT/tháng | 0 VND           |
| **Amazon CloudFront**  | Phân phối giao diện, ~100 MB dữ liệu, 1 invalidation                     | 1 TB dữ liệu truyền/tháng              | 0 VND           |
| **Amazon API Gateway** | API `student`, ~1.000 yêu cầu GET/POST                                   | 1 triệu yêu cầu REST API/tháng         | 0 VND           |
| **AWS Lambda**         | 3 functions, ~3.000 lần gọi, 128 MB RAM, 200ms (~768.000 GB-giây)       | 1 triệu lần gọi, 400.000 GB-giây/tháng |  Soliciting a Response from an Unavailable Recipient0 VND           |
| **Amazon DynamoDB**    | Bảng `studentData`, ~1.000 đọc/ghi, ~1 MB lưu trữ                        | 25 đơn vị đọc/ghi, 25 GB lưu trữ/tháng | 0 VND           |
| **Amazon SES**         | ~100 email thông báo sao lưu                                            | 62.000 email/tháng (hạn chế với Lambda) | ~2.500 VND      |
| **Amazon EventBridge** | Rule `DailyDynamoDBBackup`, ~10 sự kiện                                  | 5.000 sự kiện/tháng                    | 0 VND           |
| **Amazon CloudWatch**  | ~1 MB log cho Lambda, API Gateway                                       | 5 GB lưu trữ log/tháng                 | 0 VND           |

**Tổng Chi Phí AWS**:
- **Trong Free Tier**: ~0 VND (trừ SES).
- **Tối Đa**: ~2.500 VND/workshop (chủ yếu từ SES).
- **Lưu Ý**: Chi phí ~0 nếu dọn dẹp tài nguyên (Phần 12). Nếu không dọn dẹp, chi phí lưu trữ (S3, DynamoDB) hoặc log (CloudWatch) có thể phát sinh (~0.02–0.03 USD/tháng).

---

## Risk Assessment

### Rủi Ro Kỹ Thuật
- **Lỗi Cấu Hình**: CORS, OAI, API key gây lỗi 403/404.
  - **Giải Pháp**: Hướng dẫn chi tiết, kiểm tra qua AWS CLI (VD: `aws cloudfront get-distribution`).
- **Vượt Free Tier**: Chi phí SES hoặc CloudWatch Logs.
  - **Giải Pháp**: Giới hạn email SES (~50/workshop), tắt log sau kiểm tra.

### Rủi Ro Vận Hành
- **Thiếu Tài Nguyên**: Không đủ tài khoản AWS hoặc quyền quản trị.
  - **Giải Pháp**: Phối hợp với AWS Training để cung cấp tài khoản tạm thời.
- **Thời Gian**: Một số người cần thêm thời gian cấu hình.
  - **Giải Pháp**: Video demo, trợ giảng hỗ trợ.

### Rủi Ro Bảo Mật
- **Lộ API Key**: Nhúng `StudentApiKey` trong `scripts.js`.
  - **Giải Pháp**: Sử dụng CloudFront Functions:
    ```javascript
    function handler(event) {
        var request = event.request;
        request.headers['x-api-key'] = { value: 'xxxxxxxxxxxxxxxxxxxx' };
        return request;
    }
    ```

### Rủi Ro Chi Phí
- **Chi Phí Dư Thừa**: Tài nguyên không dọn dẹp.
  - **Giải Pháp**: Thực hiện Phần 12, kiểm tra AWS Billing Dashboard.

---

## Expected Outcomes

- **Kỹ Năng**: Thành thạo S3, CloudFront, API Gateway, Lambda, DynamoDB, SES, EventBridge.
- **Dự Án**: Hệ thống quản lý sinh viên serverless, tùy chỉnh được.
- **Bảo Mật**: Áp dụng API key, CORS, OAI, CloudFront Functions.
- **Tối Ưu Chi Phí**: Nắm quy trình dọn dẹp tài nguyên.
- **Portfolio**: Dự án thực tế bổ sung vào hồ sơ.
- **Phản Hồi**: Khảo sát cải thiện workshop.

---

## Kết Luận

Workshop cung cấp trải nghiệm thực tiễn qua **12 phần**, giúp làm chủ kiến trúc serverless trên AWS. Với chi phí AWS tối thiểu (~0–2.500 VND nếu sử dụng Free Tier và dọn dẹp đúng cách), chương trình đảm bảo xây dựng hệ thống hoàn chỉnh, áp dụng thực tiễn tốt nhất về bảo mật và tối ưu chi phí. Đây là lựa chọn lý tưởng cho tổ chức giáo dục, trung tâm đào tạo và doanh nghiệp.

**Bước Tiếp Theo**:
- Phê duyệt đề xuất và lên lịch tổ chức.
- Phối hợp với AWS Training để thiết lập tài khoản đào tạo.
- Phân phối tài liệu, mã nguồn, video demo.

**Liên Hệ**:
- Nguyễn Tri Bão Thắng: [nguyentribaothang@gmail.com](mailto:nguyentribaothang@gmail.com)
- Võ Thành Trung: [vothanhtrung9379@gmail.com](mailto:vothanhtrung9379@gmail.com)

---

📚 **Tài Liệu Tham Khảo**:
- [AWS Serverless Workshops](https://aws.amazon.com/serverless/)
- [VTI Cloud](https://vticloud.io/)
- [Techmaster Vietnam](https://techmaster.vn/)

🌟 **Cảm ơn bạn đã quan tâm đến workshop của chúng tôi!**