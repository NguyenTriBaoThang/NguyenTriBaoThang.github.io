---
title: "Giới Thiệu"
date: 2023-10-25
weight: 1
chapter: false
pre: "<b>1. </b>"
---

> **Khám phá tương lai của phát triển web!**  
> Workshop này sẽ dẫn bạn qua hành trình xây dựng một ứng dụng web **serverless** tiên tiến, tận dụng sức mạnh của AWS để quản lý thông tin sinh viên một cách **an toàn**, **hiệu quả**, và **tiết kiệm chi phí**.

Trong bối cảnh công nghệ hiện đại, việc xây dựng các ứng dụng web hiệu quả, linh hoạt và tiết kiệm chi phí là mục tiêu hàng đầu của các nhà phát triển. Workshop **"Triển khai Website Serverless Quản Lý Thông Tin Sinh Viên với Dịch Vụ AWS"** hướng dẫn bạn từng bước phát triển một website serverless, tận dụng các dịch vụ mạnh mẽ của AWS để quản lý thông tin sinh viên một cách an toàn và tối ưu.  

Ứng dụng hỗ trợ:
- **Nhập và truy xuất dữ liệu sinh viên** với các trường thông tin: **Mã sinh viên**, **Họ tên**, **Lớp**, **Ngày sinh**, và **Email**.  
- **Giao diện trực quan** được thiết kế bằng **Tailwind CSS**, mang lại trải nghiệm người dùng mượt mà.  
- **Kiến trúc serverless**, loại bỏ nhu cầu quản lý máy chủ.  
- **Tính năng nâng cao**: Bảo mật, thông báo qua email, và sao lưu tự động để đáp ứng nhu cầu thực tiễn.

---

## Lợi Ích của Ứng Dụng Serverless

Kiến trúc serverless của AWS mang lại những ưu điểm vượt trội, giúp bạn xây dựng một hệ thống quản lý thông tin sinh viên không chỉ hiệu quả mà còn dễ dàng mở rộng và duy trì. Dưới đây là các lợi ích chính:

### 1. Tự Động Mở Rộng
AWS Lambda tự động điều chỉnh tài nguyên theo lưu lượng truy cập, đảm bảo ứng dụng hoạt động mượt mà dù số lượng người dùng tăng đột biến.  

> **Ví dụ thực tiễn**: Khi hàng trăm sinh viên truy cập cùng lúc để xem hoặc cập nhật thông tin, Lambda tự động phân bổ tài nguyên mà không cần bạn can thiệp, giúp:  
> - Tối ưu hóa chi phí vận hành.  
> - Tránh lãng phí tài nguyên khi hệ thống ít sử dụng.

### 2. Bảo Mật Tối Ưu
API Gateway sử dụng **API Key** để xác thực các yêu cầu, đảm bảo chỉ những người dùng được phép mới có thể truy cập dữ liệu. Hệ thống tích hợp **IAM (Identity and Access Management)** với các vai trò riêng biệt như:  
- `LambdaGetStudentRole`  
- `LambdaInsertStudentRole`  
- `DynamoDBBackupRole`  

> **Ví dụ thực tiễn**: Hàm Lambda truy xuất dữ liệu chỉ được phép đọc từ DynamoDB, trong khi hàm sao lưu chỉ ghi vào S3, tuân thủ nguyên tắc **quyền tối thiểu (least privilege)**.  
> **Lợi ích**:  
> - Bảo vệ dữ liệu nhạy cảm.  
> - Giảm nguy cơ tấn công hoặc rò rỉ thông tin.

### 3. Thông Báo Qua Email
AWS SES (Simple Email Service) cung cấp thông báo tự động:  
1. **Xác nhận lưu dữ liệu**: Gửi email chứa chi tiết về **Mã sinh viên**, **Họ tên**, **Lớp**, và **Ngày sinh** khi dữ liệu được lưu vào DynamoDB.  
2. **Sao lưu dữ liệu**: Gửi email với **pre-signed URL** (hết hạn sau 1 giờ) khi dữ liệu được sao lưu vào S3.  

> **Lợi ích**: Cập nhật trạng thái hệ thống tức thời, đảm bảo thông báo đáng tin cậy và chuyên nghiệp.

### 4. Tiết Kiệm Chi Phí
Mô hình serverless chỉ tính phí dựa trên tài nguyên thực tế sử dụng:  
- **Lambda**: Tính phí theo số lần thực thi và thời gian chạy.  
- **S3**: Tính phí theo dung lượng lưu trữ.  
- **CloudFront**: Tính phí dựa trên dữ liệu truyền tải.  

> **Ví dụ thực tiễn**: Phù hợp cho các ứng dụng có lưu lượng truy cập không ổn định, giúp giảm chi phí vận hành đáng kể so với mô hình máy chủ truyền thống.

### 5. Hiệu Suất Cao
AWS CloudFront, một dịch vụ **CDN (Content Delivery Network)**, phân phối nội dung tĩnh (HTML, JavaScript) từ S3 đến người dùng trên toàn cầu với độ trễ thấp.  

> **Cách hoạt động**: Lưu trữ nội dung tại các **Edge Locations** gần người dùng.  
> **Ví dụ thực tiễn**: Sinh viên truy cập từ Việt Nam, Mỹ, hay châu Âu đều có trải nghiệm mượt mà, nhanh chóng.  
> **Lợi ích**: Tăng tốc độ tải trang, cải thiện trải nghiệm người dùng.

### 6. Sao Lưu Tự Động
Hệ thống tự động sao lưu dữ liệu từ DynamoDB vào S3 theo lịch trình được thiết lập qua **EventBridge** (mặc định: **7:00 AM +07** hàng ngày).  

> **Quy trình**: Hàm Lambda `BackupDynamoDBAndSendEmail` tạo tệp JSON chứa toàn bộ dữ liệu sinh viên, lưu vào bucket S3 và gửi **pre-signed URL** (hết hạn sau 1 giờ).  
> **Ví dụ thực tiễn**: Dễ dàng khôi phục dữ liệu sau sự cố, đảm bảo an toàn dữ liệu.  
> **Lợi ích**:  
> - Bảo vệ dữ liệu lâu dài.  
> - Tự động hóa quy trình sao lưu, tiết kiệm thời gian.

---

## Mục Tiêu của Workshop

Workshop này không chỉ giúp bạn triển khai một **website quản lý thông tin sinh viên** mà còn cung cấp **kiến thức thực tiễn** về cách tích hợp các dịch vụ AWS trong một kiến trúc serverless. Bạn sẽ học cách:

| **Mục Tiêu** | **Công Nghệ** | **Kết Quả** |
|--------------|---------------|-------------|
| Thiết kế giao diện web hiện đại | Tailwind CSS | Giao diện trực quan, thân thiện với người dùng |
| Tạo và bảo mật API | API Gateway, API Key | API an toàn, dễ tích hợp và mở rộng |
| Xử lý và lưu trữ dữ liệu | Lambda, DynamoDB | Quản lý dữ liệu hiệu quả, đáng tin cậy |
| Gửi thông báo qua email | SES | Thông báo tức thời, chuyên nghiệp |
| Phân phối nội dung toàn cầu | CloudFront | Truy cập nhanh, độ trễ thấp từ mọi khu vực |
| Tự động hóa sao lưu dữ liệu | S3, EventBridge | Dữ liệu an toàn, dễ khôi phục |
| Giám sát hoạt động hệ thống | CloudWatch | Theo dõi và tối ưu hiệu suất hệ thống |

---

## Bắt Đầu Hành Trình Của Bạn!

Bằng cách hoàn thành workshop, bạn sẽ sở hữu:
1. Một **ứng dụng serverless hoàn chỉnh**, sẵn sàng sử dụng trong thực tế.  
2. **Kỹ năng chuyên sâu** để phát triển các ứng dụng serverless với AWS.  
3. **Tự tin** trong việc tích hợp các dịch vụ cloud vào dự án cá nhân hoặc doanh nghiệp.

> **Sẵn sàng tham gia?**
> Chuyển đến [Các bước chuẩn bị](2-preparation-steps/) để khám phá chi tiết các bước chuẩn bị!