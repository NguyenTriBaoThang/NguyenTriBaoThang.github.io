---
title: "Tạo IAM Role cho DynamoDB Backup"
date: 2025-07-09
weight: 3
chapter: false
pre: "<b>2.3. </b>"
---

> **Mục tiêu**: Tạo vai trò IAM **DynamoDBBackupRole** cho hàm Lambda `BackupDynamoDBAndSendEmail`, cấp quyền để **đọc và ghi dữ liệu** vào bảng DynamoDB `studentData`, **lưu tệp backup** vào S3, **gửi email** qua SES, **ghi log** vào CloudWatch, và hỗ trợ tương tác tiềm năng với CloudFront.

Hàm **BackupDynamoDBAndSendEmail** thực hiện:  
- **Đọc dữ liệu** sinh viên (**Mã sinh viên**, **Họ tên**, **Lớp**, **Ngày sinh**, **Email**) từ bảng DynamoDB `studentData` qua thao tác **Scan**.  
- **Lưu tệp JSON** vào bucket S3 (ví dụ: `student-backup-20250706`).  
- **Tạo pre-signed URL** cho tệp backup và **gửi email thông báo** qua SES (ví dụ: đến `nguyentribaothang@gmail.com`).  
- **Ghi log** vào CloudWatch để giám sát hoạt động.  

Vai trò này cần:  
- Quyền **đọc và ghi dữ liệu** vào DynamoDB (`AmazonDynamoDBFullAccess`).  
- Quyền **lưu và tạo URL** trên S3 (`AmazonS3FullAccess`).  
- Quyền **gửi email** qua SES (`AmazonSESFullAccess`).  
- Quyền **ghi log** vào CloudWatch (`AWSLambdaBasicExecutionRole`).  
- Quyền **CloudFront** (`CloudFrontFullAccess`) cho các tính năng mở rộng tiềm năng.  

> **Lưu ý**: `CloudFrontFullAccess` không được sử dụng hiện tại nhưng giữ lại cho các tính năng tương lai (ví dụ: quản lý CloudFront distribution).

---

## Hành Động Chi Tiết

Dưới đây là các bước chi tiết để tạo vai trò IAM **DynamoDBBackupRole**:

### 1. Truy Cập AWS Management Console
- Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS.
- Trong thanh tìm kiếm, nhập **IAM** và chọn **Identity and Access Management (IAM)**.
- Đảm bảo bạn ở vùng AWS chính (ví dụ: `us-east-1`), kiểm tra ở góc trên bên phải.

  ![IAM - Truy cập dịch vụ](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-01.png)
  *Hình 1: Giao diện AWS Console với thanh tìm kiếm IAM.*

### 2. Điều Hướng Đến Mục Roles
- Trong giao diện IAM, tìm **menu điều hướng bên trái**.
- Chọn **Roles (Vai trò)** để xem danh sách các vai trò IAM. Nếu chưa có vai trò, danh sách sẽ trống.

  ![IAM - Danh sách vai trò](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-02.png)
  *Hình 2: Menu điều hướng với tùy chọn Roles.*

### 3. Khởi Tạo Quá Trình Tạo Vai Trò
- Trong giao diện **Roles**, nhấn **Create Role (Tạo Vai trò)** ở góc trên bên phải.

  ![IAM - Nút Create Role](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-03.png)
  *Hình 3: Nút Create Role trong giao diện Roles.*

### 4. Chọn Trusted Entity Type
- Trong mục **Select trusted entity**, chọn **AWS Service** để chỉ định vai trò dành cho dịch vụ AWS.
- Trong phần **Use case**, chọn **Lambda** từ danh sách dịch vụ.
- Nhấn **Next** để chuyển sang cấu hình quyền.

  ![IAM - Chọn Lambda Service](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-04.png)
  *Hình 4: Lựa chọn AWS Service và Lambda trong Use case.*

### 5. Cấp Quyền Cho Vai Trò
- Trong mục **Permissions (Quyền)**, thêm năm chính sách:
  - **AmazonDynamoDBFullAccess**:
    - Nhập `AmazonDynamoDBFullAccess` vào thanh tìm kiếm.
    - Chọn chính sách **AmazonDynamoDBFullAccess**.  
      > **Mô tả**: Cấp quyền đọc và ghi dữ liệu vào DynamoDB, hỗ trợ thao tác **Scan** và các thao tác khác nếu cần.

    ![IAM - Thêm AmazonDynamoDBFullAccess](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-05.png)
    *Hình 5: Chọn chính sách AmazonDynamoDBFullAccess.*

  - **AmazonS3FullAccess**:
    - Nhập `AmazonS3FullAccess` vào thanh tìm kiếm.
    - Chọn chính sách **AmazonS3FullAccess**.  
      > **Mô tả**: Cấp quyền lưu tệp backup vào S3 (`PutObject`) và tạo pre-signed URL (`GeneratePresignedUrl`).

    ![IAM - Thêm AmazonS3FullAccess](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-06.png)
    *Hình 6: Chọn chính sách AmazonS3FullAccess.*

  - **AmazonSESFullAccess**:
    - Nhập `AmazonSESFullAccess` vào thanh tìm kiếm.
    - Chọn chính sách **AmazonSESFullAccess**.  
      > **Mô tả**: Cấp quyền gửi email qua SES để thông báo link tải backup (ví dụ: đến `nguyentribaothang@gmail.com`).

    ![IAM - Thêm AmazonSESFullAccess](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-07.png)
    *Hình 7: Chọn chính sách AmazonSESFullAccess.*

  - **AWSLambdaBasicExecutionRole**:
    - Nhập `AWSLambdaBasicExecutionRole` vào thanh tìm kiếm.
    - Chọn chính sách **AWSLambdaBasicExecutionRole**.  
      > **Mô tả**: Cho phép hàm Lambda ghi log vào CloudWatch để giám sát và gỡ lỗi.

    ![IAM - Thêm AWSLambdaBasicExecutionRole](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-08.png)
    *Hình 8: Chọn chính sách AWSLambdaBasicExecutionRole.*

  - **CloudFrontFullAccess**:
    - Nhập `CloudFrontFullAccess` vào thanh tìm kiếm.
    - Chọn chính sách **CloudFrontFullAccess**.  
      > **Mô tả**: Cấp quyền quản lý CloudFront distribution cho các tính năng mở rộng tiềm năng.

    ![IAM - Thêm CloudFrontFullAccess](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-09.png)
    *Hình 9: Chọn chính sách CloudFrontFullAccess.*

- Kiểm tra danh sách **Permissions policies** để đảm bảo có:  
  - `AmazonDynamoDBFullAccess`  
  - `AmazonS3FullAccess`  
  - `AmazonSESFullAccess`  
  - `AWSLambdaBasicExecutionRole`  
  - `CloudFrontFullAccess`  
- Nhấn **Next**.

### 6. Đặt Tên và Kiểm Tra Vai Trò
- Trong mục **Role details**:
  - **Role Name**: Nhập `DynamoDBBackupRole`.  
    > **Lưu ý**: Tên phải chính xác để khớp với cấu hình hàm Lambda `BackupDynamoDBAndSendEmail`.
  - **Description** (tùy chọn): Nhập mô tả, ví dụ: _"Vai trò IAM cho hàm Lambda BackupDynamoDBAndSendEmail, cấp quyền đọc và ghi DynamoDB, lưu S3, gửi email SES, ghi log CloudWatch, và hỗ trợ CloudFront."_
  
  ![IAM - Đặt tên vai trò](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-10.png)
  *Hình 10: Nhập tên và mô tả vai trò.*

- Kiểm tra lại:
  - **Trusted entity**: AWS Service (Lambda).
  - **Permissions**: `AmazonDynamoDBFullAccess`, `AmazonS3FullAccess`, `AmazonSESFullAccess`, `AWSLambdaBasicExecutionRole`, `CloudFrontFullAccess`.
- Nhấn **Create Role (Tạo Vai trò)**.

  ![IAM - Xác nhận tạo vai trò](/images/1-iam-role/dynamodb-backup/iam-role-dynamodb-backup-11.png)
  *Hình 11: Nút Create Role để xác nhận.*

### 7. Kiểm Tra Trạng Thái Tạo Vai Trò
- Sau khi nhấn **Create Role**, bạn sẽ trở về danh sách **Roles**.
- Tìm vai trò **DynamoDBBackupRole**. Nếu thành công, bạn sẽ thấy thông báo: _"Role DynamoDBBackupRole created"_.
- Nhấp vào **DynamoDBBackupRole** để xem chi tiết:
  - **ARN**: Ghi lại ARN (ví dụ: `arn:aws:iam::your-account-id:role/DynamoDBBackupRole`) để sử dụng khi cấu hình hàm Lambda.
  - **Policies**: Xác minh có `AmazonDynamoDBFullAccess`, `AmazonS3FullAccess`, `AmazonSESFullAccess`, `AWSLambdaBasicExecutionRole`, `CloudFrontFullAccess`.
- Nếu vai trò không xuất hiện, làm mới trang hoặc kiểm tra lại các bước.

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Tên vai trò** | Phải là `DynamoDBBackupRole` (phân biệt chữ hoa/thường) để khớp với hàm Lambda. Tên sai sẽ gây lỗi khi thực thi. |
| **CloudFront** | `CloudFrontFullAccess` không được sử dụng hiện tại nhưng giữ lại cho các tính năng mở rộng. Xóa nếu không cần để tuân thủ **least privilege**. |
| **S3 và SES** | Đảm bảo bucket S3 (ví dụ: `student-backup-20250706`) tồn tại và email nguồn (ví dụ: `nguyentribaothang@gmail.com`) đã được xác minh trong SES. |
| **Kiểm tra sớm** | Ghi lại **ARN** và kiểm tra vai trò trong IAM trước khi cấu hình hàm Lambda để đảm bảo hoạt động đúng. |
| **Xử lý lỗi** | Nếu gặp lỗi "Access Denied", kiểm tra quyền tài khoản AWS (`iam:CreateRole`, `iam:AttachRolePolicy`) hoặc liên hệ quản trị viên. Nếu hàm báo lỗi `AccessDenied`, kiểm tra chính sách S3 hoặc SES. Dùng CloudTrail hoặc IAM Access Advisor để xác định vấn đề. |
| **Vùng AWS** | Đảm bảo vùng AWS (ví dụ: `us-east-1`) nhất quán với các dịch vụ (DynamoDB, Lambda, SES, S3). Kiểm tra ở góc trên bên phải AWS Console. |

> **Mẹo thực tiễn**: Kiểm tra bucket S3 và trạng thái xác minh email trong SES trước khi chạy hàm Lambda để tránh lỗi `AccessDenied`.

---

## Kết Luận

Vai trò IAM **DynamoDBBackupRole** đảm bảo hàm Lambda `BackupDynamoDBAndSendEmail` có quyền **đọc và ghi dữ liệu** vào DynamoDB, **lưu tệp** vào S3, **gửi email** qua SES, và **ghi log** vào CloudWatch, đồng thời hỗ trợ mở rộng với CloudFront. Vai trò này sẵn sàng tích hợp vào hàm Lambda trong các bước tiếp theo.

> **Bước tiếp theo**: Chuyển đến [Tạo bảng trong DynamoDB](/2-Prerequiste/2.4-createtable-in-dynamodb/) để thiết lập bảng dữ liệu!