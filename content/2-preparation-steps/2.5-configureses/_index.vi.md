---
title: "Cấu hình Amazon SES"
date: 2023-10-25
weight: 5
chapter: false
pre: "<b>2.5 </b>"
---

> **Mục tiêu**: Cấu hình Amazon SES để gửi email xác nhận cho hàm Lambda `insertStudentData` (xác nhận khi lưu dữ liệu sinh viên) và `BackupDynamoDBAndSendEmail` (thông báo link tải tệp backup). Xác minh địa chỉ email (ví dụ: `nguyentribaothang@gmail.com`) và thoát chế độ sandbox để gửi email đến các địa chỉ chưa xác minh.

Amazon SES là dịch vụ gửi email của AWS với độ tin cậy cao và chi phí thấp, dùng để:  
- Gửi email xác nhận khi thêm sinh viên vào bảng DynamoDB `studentData`.  
- Gửi email thông báo chứa pre-signed URL của tệp backup từ S3.  

> **Lưu ý**: Tài khoản SES mặc định ở chế độ **sandbox**, chỉ cho phép gửi email đến địa chỉ đã xác minh. Thoát sandbox là cần thiết để gửi email đến địa chỉ sinh viên (chưa xác minh).

---

## Hành Động Chi Tiết

Dưới đây là các bước chi tiết để cấu hình SES:

### 1. Truy Cập AWS Management Console
- Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)**.
- Trong thanh tìm kiếm, nhập **SES** và chọn **Amazon Simple Email Service (SES)**.
- Đảm bảo bạn ở vùng AWS hỗ trợ SES (ví dụ: `us-east-1`), kiểm tra ở góc trên bên phải.

  ![SES - Truy cập dịch vụ](/images/3-configureses/configureses-01.png)
  *Hình 1: Giao diện AWS Console với thanh tìm kiếm SES.*

### 2. Điều Hướng Đến Mục Verified Identities
- Trong giao diện SES, tìm **menu điều hướng bên trái**.
- Chọn **Verified identities (Danh tính đã xác minh)** để xem danh sách email hoặc domain đã xác minh. Nếu chưa có, danh sách sẽ trống.

  ![SES - Danh sách danh tính](/images/3-configureses/configureses-02.png)
  *Hình 2: Menu điều hướng với tùy chọn Verified identities.*

### 3. Khởi Tạo Quá Trình Tạo Danh Tính
- Trong giao diện **Verified identities**, nhấn **Create identity (Tạo danh tính)** ở góc trên bên phải.

  ![SES - Nút Create Identity](/images/3-configureses/configureses-03.png)
  *Hình 3: Nút Create Identity trong giao diện Verified identities.*

### 4. Cấu Hình Địa Chỉ Email
- Trong mục **Identity type**, chọn **Email address**.
- Trong trường **Email address**, nhập địa chỉ email nguồn (ví dụ: `nguyentribaothang@gmail.com`).  
  > **Lưu ý**: Dùng email bạn có quyền truy cập để nhận email xác minh. Tránh sử dụng email mẫu như `example@gmail.com`.
- Giữ các thiết lập mặc định (không cần Feedback notifications hoặc DKIM settings).
- Nhấn **Create identity** để gửi yêu cầu xác minh.

  ![SES - Cấu hình email](/images/3-configureses/configureses-04.png)
  *Hình 4: Giao diện cấu hình địa chỉ email.*

### 5. Kiểm Tra và Xác Minh Email
- AWS SES gửi email xác minh đến địa chỉ đã nhập (ví dụ: `nguyentribaothang@gmail.com`).
- Đăng nhập vào tài khoản email, kiểm tra **Inbox** hoặc **Spam/Junk** để tìm email từ AWS (tiêu đề như _"Amazon Web Services - Email Address Verification Request"_).
- Nhấp vào đường dẫn xác minh trong email để hoàn tất.
- Quay lại SES, làm mới trang **Verified identities**. Xác nhận trạng thái là **Verified**.

  ![SES - Xác minh email](/images/3-configureses/configureses-05.png)
  *Hình 5: Kiểm tra trạng thái Verified của email.*

### 6. Kiểm Tra Chế Độ Sandbox và Yêu Cầu Thoát Sandbox
- **Kiểm tra sandbox**:
  - Trong SES, vào **Account dashboard** hoặc **Sending statistics**.
  - Kiểm tra mục **Account status**. Nếu hiển thị _"Your account is in the sandbox"_, tài khoản đang giới hạn gửi email đến địa chỉ đã xác minh.
- **Yêu cầu thoát sandbox**:
  - Trong **Account dashboard**, nhấn **Edit your account details** hoặc **Request production access**.
  - Điền biểu mẫu:
    - **Use case description**: _"Gửi email xác nhận khi lưu thông tin sinh viên và thông báo sao lưu dữ liệu từ DynamoDB."_
    - **Mail type**: Chọn **Transactional**.
    - **Website URL**: Nhập URL ứng dụng (nếu có) hoặc ghi _"Website đang phát triển."_
    - **Sender email address**: Nhập email đã xác minh (ví dụ: `nguyentribaothang@gmail.com`).
    - **Additional information**: _"Cần gửi email đến địa chỉ sinh viên chưa xác minh cho hệ thống quản lý thông tin sinh viên."_
  - Gửi yêu cầu. AWS phê duyệt trong **24-48 giờ**, thông báo qua email.
- **Giải pháp tạm thời**: Trong sandbox, xác minh thêm email nhận (theo bước 4–5) hoặc sửa mã Lambda để chỉ gửi đến email đã xác minh.

### 7. Xác Minh và Thử Nghiệm SES
- Quay lại **Verified identities**, kiểm tra trạng thái email (ví dụ: `nguyentribaothang@gmail.com`) là **Verified**.
- Trong SES, chọn **Send a test email** (nếu có), gửi email thử đến email đã xác minh để kiểm tra hoạt động.
- Nếu trạng thái vẫn là **Pending**, kiểm tra lại email (Inbox/Spam) hoặc tạo lại danh tính.

  ![SES - Kiểm tra trạng thái](/images/3-configureses/configureses-06.png)
  *Hình 6: Xác nhận trạng thái Verified và thử nghiệm gửi email.*

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Email hợp lệ** | Sử dụng email bạn có quyền truy cập (ví dụ: `nguyentribaothang@gmail.com`). Nếu không nhận được email xác minh trong 5-10 phút, kiểm tra **Spam/Junk** hoặc liên hệ AWS Support. |
| **Chế độ sandbox** | Trong sandbox, chỉ gửi email đến địa chỉ đã xác minh. Thoát sandbox để gửi đến email sinh viên (chưa xác minh), hoặc hàm `insertStudentData` sẽ báo lỗi **AccessDenied**. |
| **Vùng AWS** | Cấu hình SES trong vùng hỗ trợ (ví dụ: `us-east-1`), khớp với Lambda. Kiểm tra danh sách vùng hỗ trợ SES trong [AWS SES Documentation](https://docs.aws.amazon.com/ses/latest/dg/regions.html). |
| **Xử lý lỗi** | Nếu không nhận email xác minh, kiểm tra cấu hình DNS hoặc liên hệ nhà cung cấp email. Nếu Lambda báo lỗi _"Email address is not verified"_, kiểm tra trạng thái xác minh trong SES hoặc CloudWatch logs. |
| **Tối ưu hóa** | Cân nhắc xác minh domain hoặc cấu hình DKIM cho bảo mật. Xem [AWS SES Documentation - DKIM](https://docs.aws.amazon.com/ses/latest/dg/send-email-authentication-dkim.html). |
| **Kiểm tra sớm** | Thử gửi email test từ SES trước khi tích hợp với Lambda để đảm bảo hoạt động đúng. |

> **Mẹo thực tiễn**: Sau khi xác minh email, gửi email thử từ SES để kiểm tra trước khi chạy các hàm Lambda.

---

## Kết Luận

Cấu hình SES với email đã xác minh (ví dụ: `nguyentribaothang@gmail.com`) và thoát sandbox (nếu cần) đảm bảo các hàm Lambda `insertStudentData` và `BackupDynamoDBAndSendEmail` gửi email xác nhận và thông báo thành công. SES đã sẵn sàng tích hợp vào ứng dụng serverless.

> **Bước tiếp theo**: Chuyển đến [Cấu hình Lambda Functions](3-creating-lambda-functions/) để thiết lập các hàm Lambda!