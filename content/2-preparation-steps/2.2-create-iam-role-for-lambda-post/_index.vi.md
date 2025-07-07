---
title: "Tạo IAM Role cho Lambda Post"
date: 2023-10-25
weight: 2
chapter: false
pre: "<b>2.2 </b>"
---

> **Mục tiêu**: Tạo vai trò IAM **LambdaInsertStudentRole** cho hàm Lambda `insertStudentData`, cấp quyền để **ghi dữ liệu** vào bảng DynamoDB `studentData`, **gửi email** qua AWS SES, **ghi log** vào CloudWatch, và hỗ trợ các tương tác tiềm năng với S3 và CloudFront.

Hàm **insertStudentData** thực hiện:  
- **Lưu thông tin sinh viên** (**Mã sinh viên**, **Họ tên**, **Lớp**, **Ngày sinh**, **Email**) vào bảng DynamoDB `studentData` qua thao tác **PutItem**.  
- **Gửi email xác nhận** đến địa chỉ email của sinh viên qua AWS SES.  

Vai trò này cần:  
- Quyền **ghi log** vào CloudWatch (`AWSLambdaBasicExecutionRole`).  
- Quyền **ghi và đọc dữ liệu** vào DynamoDB (`AmazonDynamoDBFullAccess`).  
- Quyền **gửi email** qua SES (`AmazonSESFullAccess`).  
- Quyền **S3** và **CloudFront** (`AmazonS3FullAccess`, `CloudFrontFullAccess`) cho các tính năng mở rộng tiềm năng.  

> **Lưu ý**: `AmazonS3FullAccess` và `CloudFrontFullAccess` không được sử dụng trong mã hiện tại nhưng được giữ lại để hỗ trợ các tính năng tương lai (ví dụ: lưu tệp vào S3 hoặc quản lý CloudFront).

---

## Hành Động Chi Tiết

Dưới đây là các bước chi tiết để tạo vai trò IAM **LambdaInsertStudentRole**:

### 1. Truy Cập AWS Management Console
- Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS của bạn.
- Trong thanh tìm kiếm ở đầu trang, nhập **IAM** và chọn **Identity and Access Management (IAM)**.
- Đảm bảo bạn đang ở vùng AWS chính (ví dụ: `us-east-1`), kiểm tra ở góc trên bên phải.

  ![IAM - Truy cập dịch vụ](/images/1-iam-role/insert-student/iam-role-insert-student-01.png)
  *Hình 1: Giao diện AWS Console với thanh tìm kiếm IAM.*

### 2. Điều Hướng Đến Mục Roles
- Trong giao diện IAM, tìm **menu điều hướng bên trái**.
- Chọn **Roles (Vai trò)** để xem danh sách các vai trò IAM. Nếu chưa có vai trò nào, danh sách sẽ trống.

  ![IAM - Danh sách vai trò](/images/1-iam-role/insert-student/iam-role-insert-student-02.png)
  *Hình 2: Menu điều hướng với tùy chọn Roles.*

### 3. Khởi Tạo Quá Trình Tạo Vai Trò
- Trong giao diện **Roles**, nhấn nút **Create Role (Tạo Vai trò)** ở góc trên bên phải.

  ![IAM - Nút Create Role](/images/1-iam-role/insert-student/iam-role-insert-student-03.png)
  *Hình 3: Nút Create Role trong giao diện Roles.*

### 4. Chọn Trusted Entity Type
- Trong mục **Select trusted entity**, chọn **AWS Service** để chỉ định vai trò dành cho dịch vụ AWS.
- Trong phần **Use case**, chọn **Lambda** từ danh sách dịch vụ.
- Nhấn **Next** để chuyển sang bước cấu hình quyền.

  ![IAM - Chọn Lambda Service](/images/1-iam-role/insert-student/iam-role-insert-student-04.png)
  *Hình 4: Lựa chọn AWS Service và Lambda trong Use case.*

### 5. Cấp Quyền Cho Vai Trò
- Trong mục **Permissions (Quyền)**, thêm các chính sách sau:
  - **AWSLambdaBasicExecutionRole**:
    - Nhập `AWSLambdaBasicExecutionRole` vào thanh tìm kiếm.
    - Chọn chính sách **AWSLambdaBasicExecutionRole**.  
      > **Mô tả**: Cho phép hàm Lambda ghi log vào CloudWatch để giám sát và gỡ lỗi.

    ![IAM - Thêm AWSLambdaBasicExecutionRole](/images/1-iam-role/insert-student/iam-role-insert-student-05.png)
    *Hình 5: Chọn chính sách AWSLambdaBasicExecutionRole.*

  - **AmazonDynamoDBFullAccess**:
    - Nhập `AmazonDynamoDBFullAccess` vào thanh tìm kiếm.
    - Chọn chính sách **AmazonDynamoDBFullAccess**.  
      > **Mô tả**: Cấp quyền đọc và ghi dữ liệu trên DynamoDB, bao gồm thao tác **PutItem** cần thiết cho hàm `insertStudentData`.

    ![IAM - Thêm AmazonDynamoDBFullAccess](/images/1-iam-role/insert-student/iam-role-insert-student-06.png)
    *Hình 6: Chọn chính sách AmazonDynamoDBFullAccess.*

  - **AmazonSESFullAccess**:
    - Nhập `AmazonSESFullAccess` vào thanh tìm kiếm.
    - Chọn chính sách **AmazonSESFullAccess**.  
      > **Mô tả**: Cấp quyền gửi email qua SES để thông báo xác nhận (ví dụ: đến `nguyentribaothang@gmail.com`).

    ![IAM - Thêm AmazonSESFullAccess](/images/1-iam-role/insert-student/iam-role-insert-student-07.png)
    *Hình 7: Chọn chính sách AmazonSESFullAccess.*

  - **AmazonS3FullAccess** (tùy chọn):
    - Nhập `AmazonS3FullAccess` vào thanh tìm kiếm.
    - Chọn chính sách **AmazonS3FullAccess**.  
      > **Mô tả**: Cấp quyền đọc, ghi, quản lý S3 bucket cho các tính năng mở rộng tiềm năng.

    ![IAM - Thêm AmazonS3FullAccess](/images/1-iam-role/insert-student/iam-role-insert-student-08.png)
    *Hình 8: Chọn chính sách AmazonS3FullAccess.*

  - **CloudFrontFullAccess** (tùy chọn):
    - Nhập `CloudFrontFullAccess` vào thanh tìm kiếm.
    - Chọn chính sách **CloudFrontFullAccess**.  
      > **Mô tả**: Cấp quyền quản lý CloudFront distribution cho các tính năng mở rộng tiềm năng.

  ![IAM - Thêm CloudFrontFullAccess](/images/1-iam-role/insert-student/iam-role-insert-student-09.png)
  *Hình 9: Chọn chính sách CloudFrontFullAccess.*

- Kiểm tra danh sách **Permissions policies** để đảm bảo có:  
  - `AWSLambdaBasicExecutionRole`  
  - `AmazonDynamoDBFullAccess`  
  - `AmazonSESFullAccess`  
  - `AmazonS3FullAccess`  
  - `CloudFrontFullAccess`  
- Nhấn **Next**.

### 6. Đặt Tên và Kiểm Tra Vai Trò
- Trong mục **Role details**:
  - **Role Name**: Nhập `LambdaInsertStudentRole`.  
    > **Lưu ý**: Tên phải chính xác để khớp với cấu hình hàm Lambda `insertStudentData`.
  - **Description** (tùy chọn): Nhập mô tả, ví dụ: _"Vai trò IAM cho hàm Lambda insertStudentData, cấp quyền ghi DynamoDB, gửi email SES, ghi log CloudWatch, và hỗ trợ S3/CloudFront."_

  ![IAM - Đặt tên vai trò](/images/1-iam-role/insert-student/iam-role-insert-student-10.png)
  *Hình 10: Nhập tên và mô tả vai trò.*

- Kiểm tra lại:
  - **Trusted entity**: AWS Service (Lambda).
  - **Permissions**: `AWSLambdaBasicExecutionRole`, `AmazonDynamoDBFullAccess`, `AmazonSESFullAccess`, `AmazonS3FullAccess`, `CloudFrontFullAccess`.
- Nhấn **Create Role (Tạo Vai trò)**.

### 7. Kiểm Tra Trạng Thái Tạo Vai Trò
- Sau khi nhấn **Create Role**, bạn sẽ trở về danh sách **Roles**.

  ![Nhấn Create Role để tạo](/images/1-iam-role/insert-student/iam-role-insert-student-11.png)
  *Hình 11: Nhập tên và mô tả vai trò.*

- Tìm vai trò **LambdaInsertStudentRole**. Nếu thành công, bạn sẽ thấy thông báo: _"Role LambdaInsertStudentRole created"_.

  ![IAM - Thông báo tạo thành công](/images/1-iam-role/insert-student/iam-role-insert-student-12.png)
  *Hình 12: Thông báo: Role LambdaInsertStudentRole created.*

- Nhấp vào **LambdaInsertStudentRole** để xem chi tiết:
  - **ARN**: Ghi lại ARN (ví dụ: `arn:aws:iam::your-account-id:role/LambdaInsertStudentRole`) để sử dụng khi cấu hình hàm Lambda.
  - **Policies**: Xác minh các chính sách đã gắn đúng.
- Nếu vai trò không xuất hiện, làm mới trang hoặc kiểm tra lại các bước.

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Tên vai trò** | Phải là `LambdaInsertStudentRole` (phân biệt chữ hoa/thường) để khớp với hàm Lambda. Tên sai sẽ gây lỗi khi thực thi. |
| **DynamoDB quyền** | `AmazonDynamoDBReadOnlyAccess` không hỗ trợ `PutItem`. Sử dụng `AmazonDynamoDBFullAccess` để cho phép `PutItem` trên bảng `studentData`. |
| **S3 và CloudFront** | `AmazonS3FullAccess` và `CloudFrontFullAccess` không được sử dụng hiện tại nhưng giữ lại cho các tính năng mở rộng (ví dụ: lưu tệp vào S3 hoặc quản lý CloudFront). Xóa nếu không cần để tuân thủ **least privilege**. |
| **Kiểm tra sớm** | Ghi lại **ARN** và kiểm tra vai trò trong IAM trước khi cấu hình hàm Lambda để đảm bảo hoạt động đúng. |
| **Xử lý lỗi** | Nếu gặp lỗi "Access Denied", kiểm tra quyền tài khoản AWS (`iam:CreateRole`, `iam:AttachRolePolicy`) hoặc liên hệ quản trị viên. Nếu hàm báo lỗi `AccessDenied`, kiểm tra chính sách DynamoDB. Dùng CloudTrail hoặc IAM Access Advisor để xác định vấn đề. |
| **Vùng AWS** | Đảm bảo vùng AWS (ví dụ: `us-east-1`) nhất quán với các dịch vụ khác (DynamoDB, Lambda, SES). Kiểm tra ở góc trên bên phải AWS Console. |

> **Mẹo thực tiễn**: Kiểm tra vai trò và ARN ngay sau khi tạo để đảm bảo cấu hình chính xác trước khi tích hợp với hàm Lambda.

---

## Kết Luận

Vai trò IAM **LambdaInsertStudentRole** đảm bảo hàm Lambda `insertStudentData` có quyền cần thiết để **ghi dữ liệu** vào DynamoDB, **gửi email** qua SES, và **ghi log** vào CloudWatch, đồng thời hỗ trợ mở rộng với S3 và CloudFront. Với `AmazonDynamoDBFullAccess`, hàm hoạt động hiệu quả và an toàn trong ứng dụng serverless.

> **Bước tiếp theo**: Chuyển đến [Tạo IAM Role cho DynamoDB Backup](/2-Prerequiste/2.3-create-iam-role-for-dynamodb-backup/) để thiết lập vai trò cho sao lưu dữ liệu!