---
title: "Tạo bảng trong DynamoDB"
date: 2023-10-25
weight: 4
chapter: false
pre: "<b>2.4 </b>"
---

> **Mục tiêu**: Thiết lập bảng **studentData** trong DynamoDB để lưu trữ thông tin sinh viên, bao gồm **Mã sinh viên (studentid)**, **Họ tên**, **Lớp**, **Ngày sinh**, và **Email**, sử dụng **studentid** (kiểu String) làm khóa chính để đảm bảo truy vấn nhanh và hiệu quả trong kiến trúc serverless.

**DynamoDB**, cơ sở dữ liệu **NoSQL** của AWS, cung cấp **mở rộng tự động** và **độ trễ thấp**, lý tưởng cho ứng dụng quản lý thông tin sinh viên. Bảng `studentData` sẽ là nền tảng để tích hợp với các dịch vụ AWS như Lambda, API Gateway, và SES.

---

## Hành Động Chi Tiết

Dưới đây là các bước chi tiết để tạo và cấu hình bảng **studentData**:

### 1. Truy Cập AWS Management Console
- Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)**.
- Trong thanh tìm kiếm, nhập **DynamoDB** và chọn **DynamoDB** để vào giao diện quản lý.

  ![DynamoDB - Truy cập dịch vụ](/images/2-dynamobd/dynamobd-01.png)
  *Hình 1: Giao diện AWS Console với thanh tìm kiếm DynamoDB.*

### 2. Điều Hướng Đến Mục Tables
- Trong giao diện DynamoDB, tìm **menu điều hướng bên trái**.
- Chọn **Tables (Bảng)** để xem danh sách các bảng hiện có. Nếu chưa có bảng, danh sách sẽ trống.

  ![DynamoDB - Danh sách bảng](/images/2-dynamobd/dynamobd-02.png)
  *Hình 2: Menu điều hướng với tùy chọn Tables.*

### 3. Khởi Tạo Quá Trình Tạo Bảng
- Trong giao diện **Tables**, nhấn **Create Table (Tạo Bảng)** ở góc trên bên phải.

  ![DynamoDB - Nút Create Table](/images/2-dynamobd/dynamobd-03.png)
  *Hình 3: Nút Create Table trong giao diện Tables.*

### 4. Cấu Hình Chi Tiết Bảng
- Trong mục **Table Details**:
  - **Table Name**: Nhập `studentData`.  
    > **Lưu ý**: Tên bảng phải khớp chính xác với mã trong các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`).
  - **Partition Key**: Nhập `studentid`, chọn kiểu **String**.  
    > **Khóa chính**: Đảm bảo mỗi sinh viên có định danh duy nhất (ví dụ: `SV001`, `SV002`).
  - **Sort Key**: Để trống (không cần, vì truy vấn dựa trên `studentid`).
- **Settings**: Sử dụng tùy chọn mặc định:
  - Chọn **On-Demand** cho **Capacity mode** để tự động điều chỉnh tài nguyên, tiết kiệm chi phí và đơn giản hóa quản lý.
  - Không cần thêm **Secondary Indexes** hoặc **Encryption** tùy chỉnh (mặc định đủ cho ứng dụng này).
- **Kiểm tra thông tin**:
  - Table Name: `studentData`
  - Partition Key: `studentid (String)`

  ![DynamoDB - Cấu hình bảng](/images/2-dynamobd/dynamobd-04.png)  
  *Hình 4: Giao diện cấu hình bảng với Table Name và Partition Key.*

### 5. Tạo Bảng
- Nhấn **Create Table (Tạo Bảng)** ở cuối trang.

  ![DynamoDB - Xác nhận tạo bảng](/images/2-dynamobd/dynamobd-05.png)
  *Hình 5: Nút Create Table để xác nhận.*

- DynamoDB sẽ tạo bảng trong khoảng **20-30 giây**, tùy vào vùng AWS (ví dụ: `us-east-1`).

  ![DynamoDB - Quá trình tạo bảng](/images/2-dynamobd/dynamobd-06.png)
  *Hình 6: Giao diện hiển thị trạng thái tạo bảng.*

### 6. Kiểm Tra Trạng Thái Bảng
- Sau khi nhấn **Create Table**, bạn sẽ trở về danh sách **Tables**.
- Tìm bảng `studentData`. Trạng thái ban đầu là **Creating**.
- Chờ khoảng **30 giây**, làm mới trang (nút **Refresh** hoặc **F5**).
- Khi trạng thái chuyển thành **Active**, bảng đã tạo thành công.
- **Thông báo**: Giao diện hiển thị _"The studentData table was created successfully"_.

  ![DynamoDB - Trạng thái Active](/images/2-dynamobd/dynamobd-07.png)
  *Hình 7: Bảng studentData với trạng thái Active.*

### 7. Xác Minh Cấu Hình Bảng
- Nhấp vào bảng `studentData` để xem chi tiết.
- Kiểm tra:
  - **Table ARN**: Ví dụ, `arn:aws:dynamodb:us-east-1:your-account-id:table/studentData`.
  - **Partition Key**: `studentid (String)`.
  - **Capacity Mode**: **On-Demand**.
  - **Sort Key**: Không có.
- Các thuộc tính khác (**Họ tên**, **Lớp**, **Ngày sinh**, **Email**) là thuộc tính động, không cần khai báo trước.

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Tên bảng** | Phải là `studentData` (phân biệt chữ hoa/thường) để khớp với mã Lambda. Tên sai gây lỗi truy vấn. |
| **Vùng AWS** | Tạo bảng trong cùng vùng AWS với các dịch vụ khác (ví dụ: `us-east-1`). Kiểm tra vùng ở góc trên bên phải AWS Console. |
| **Thời gian tạo** | Nếu trạng thái **Creating** kéo dài quá 30 giây, kiểm tra kết nối mạng hoặc làm mới trang. Nếu lỗi, xóa bảng và thử lại. |
| **Tối ưu hóa** | Với dữ liệu lớn (>500 MB), cân nhắc bật **Point-in-time Recovery (PITR)** trong tab **Backups** để hỗ trợ khôi phục. Sao lưu qua Lambda và S3 đủ cho ứng dụng này. |
| **Kiểm tra sớm** | Khi bảng ở trạng thái **Active**, vào tab **Items**, chọn **Create Item** để nhập bản ghi mẫu: <br> - `studentid`: `SV001` <br> - `name`: `Nguyễn Văn A` <br> - `class`: `CNTT1` <br> - `birthdate`: `2000-01-01` <br> - `email`: `example@gmail.com` <br> Xác minh dữ liệu hiển thị đúng. |

> **Mẹo thực tiễn**: Kiểm tra cấu hình bảng ngay sau khi tạo để đảm bảo tính chính xác trước khi tích hợp với Lambda.

---

## Kết Luận

Bảng `studentData` là nền tảng để lưu trữ và quản lý thông tin sinh viên trong ứng dụng serverless. Với khóa chính `studentid` và chế độ **On-Demand**, bảng đảm bảo **hiệu suất cao**, **mở rộng linh hoạt**, và **độ trễ thấp**. Bảng đã sẵn sàng tích hợp với **Lambda**, **API Gateway**, và **SES**.

> **Bước tiếp theo**: Chuyển đến [Cấu hình SES](/2-prerequisite/2.5-configure-ses/) để thiết lập dịch vụ gửi email!