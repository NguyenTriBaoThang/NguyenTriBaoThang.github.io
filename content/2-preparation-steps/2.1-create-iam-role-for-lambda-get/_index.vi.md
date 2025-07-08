---
title: "Tạo IAM Role cho Lambda Get"
date: 2023-10-25
weight: 2
chapter: false
pre: "<b>2.1. </b>"
---


> **Mục tiêu**: Tạo vai trò IAM **LambdaGetStudentRole** cho hàm Lambda `getStudentData`, cấp quyền để **đọc dữ liệu** từ bảng DynamoDB `studentData`, **ghi log** vào CloudWatch, và hỗ trợ các tương tác tiềm năng với S3 và CloudFront.

Hàm **getStudentData** thực hiện thao tác **Scan** để truy xuất toàn bộ dữ liệu sinh viên (**Mã sinh viên**, **Họ tên**, **Lớp**, **Ngày sinh**, **Email**) từ bảng DynamoDB `studentData`. Vai trò này cần:  
- Quyền **ghi log** vào CloudWatch (`AWSLambdaBasicExecutionRole`).  
- Quyền **đọc dữ liệu** từ DynamoDB (`AmazonDynamoDBReadOnlyAccess`).  
- Quyền **S3** và **CloudFront** (`AmazonS3FullAccess`, `CloudFrontFullAccess`) cho các tính năng mở rộng tiềm năng.  

> **Lưu ý**: `AmazonS3FullAccess` và `CloudFrontFullAccess` không được sử dụng trong mã hiện tại nhưng được giữ lại để hỗ trợ các tính năng tương lai (ví dụ: lưu tệp vào S3 hoặc quản lý CloudFront).

---

## Hành Động Chi Tiết

Dưới đây là các bước chi tiết để tạo vai trò IAM **LambdaGetStudentRole**:

### 1. Truy Cập AWS Management Console
- Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS của bạn.
- Trong thanh tìm kiếm ở đầu trang, nhập **IAM** và chọn **Identity and Access Management (IAM)**.

  ![IAM - Truy cập dịch vụ](/images/1-iam-role/get-student/iam-role-get-student-01.png)
  *Hình 1: Giao diện AWS Console với thanh tìm kiếm IAM.*

### 2. Điều Hướng Đến Mục Roles
- Trong giao diện IAM, tìm **menu điều hướng bên trái**.
- Chọn **Roles (Vai trò)** để xem danh sách các vai trò IAM. Nếu chưa có vai trò nào, danh sách sẽ trống.

  ![IAM - Danh sách vai trò](/images/1-iam-role/get-student/iam-role-get-student-02.png)
  *Hình 2: Menu điều hướng với tùy chọn Roles.*

### 3. Khởi Tạo Quá Trình Tạo Vai Trò
- Trong giao diện **Roles**, nhấn nút **Create Role (Tạo Vai trò)** ở góc trên bên phải.

  ![IAM - Nút Create Role](/images/1-iam-role/get-student/iam-role-get-student-03.png)
  *Hình 3: Nút Create Role trong giao diện Roles.*

### 4. Chọn Trusted Entity Type
- Trong mục **Select trusted entity**, chọn **AWS Service** để chỉ định vai trò dành cho dịch vụ AWS.
- Trong phần **Use case**, chọn **Lambda** từ danh sách dịch vụ.
- Nhấn **Next** để chuyển sang bước cấu hình quyền.

  ![IAM - Chọn Lambda Service](/images/1-iam-role/get-student/iam-role-get-student-04.png)
  *Hình 4: Lựa chọn AWS Service và Lambda trong Use case.*

### 5. Cấp Quyền Cho Vai Trò
- Trong mục **Permissions (Quyền)**, thêm bốn chính sách:
  - **AWSLambdaBasicExecutionRole**:
    - Nhập `AWSLambdaBasicExecutionRole` vào thanh tìm kiếm.
    - Chọn chính sách **AWSLambdaBasicExecutionRole**.  
      > **Mô tả**: Cho phép hàm Lambda ghi log vào CloudWatch để giám sát và gỡ lỗi.

    ![IAM - Thêm AWSLambdaBasicExecutionRole](/images/1-iam-role/get-student/iam-role-get-student-05.png)
    *Hình 5: Chọn chính sách AWSLambdaBasicExecutionRole.*

  - **AmazonDynamoDBReadOnlyAccess**:
    - Nhập `AmazonDynamoDBReadOnlyAccess` vào thanh tìm kiếm.
    - Chọn chính sách **AmazonDynamoDBReadOnlyAccess**.  
      > **Mô tả**: Cấp quyền đọc dữ liệu từ DynamoDB, hỗ trợ thao tác **Scan** hoặc **GetItem**.

    ![IAM - Thêm AmazonDynamoDBReadOnlyAccess](/images/1-iam-role/get-student/iam-role-get-student-06.png)
    *Hình 6: Chọn chính sách AmazonDynamoDBReadOnlyAccess.*

  - **AmazonS3FullAccess**:
    - Nhập `AmazonS3FullAccess` vào thanh tìm kiếm.
    - Chọn chính sách **AmazonS3FullAccess**.  
      > **Mô tả**: Cấp quyền đọc, ghi, quản lý S3 bucket cho các tính năng mở rộng tiềm năng (ví dụ: lưu tệp bổ sung).

    ![IAM - Thêm AmazonS3FullAccess](/images/1-iam-role/get-student/iam-role-get-student-07.png)
    *Hình 7: Chọn chính sách AmazonS3FullAccess.*

  - **CloudFrontFullAccess**:
    - Nhập `CloudFrontFullAccess` vào thanh tìm kiếm.
    - Chọn chính sách **CloudFrontFullAccess**.  
      > **Mô tả**: Cấp quyền quản lý CloudFront distribution cho các tính năng mở rộng tiềm năng.

    ![IAM - Thêm CloudFrontFullAccess](/images/1-iam-role/get-student/iam-role-get-student-08.png)
    *Hình 8: Chọn chính sách CloudFrontFullAccess.*

- Kiểm tra danh sách **Permissions policies** để đảm bảo có:  
  - `AWSLambdaBasicExecutionRole`  
  - `AmazonDynamoDBReadOnlyAccess`  
  - `AmazonS3FullAccess`  
  - `CloudFrontFullAccess`  
- Nhấn **Next**.

### 6. Đặt Tên và Kiểm Tra Vai Trò
- Trong mục **Role details**:
  - **Role Name**: Nhập `LambdaGetStudentRole`.  
    > **Lưu ý**: Tên phải chính xác để khớp với cấu hình hàm Lambda `getStudentData`.
  - **Description** (tùy chọn): Nhập mô tả, ví dụ: _"Vai trò IAM cho hàm Lambda getStudentData, cấp quyền đọc DynamoDB, ghi log CloudWatch, và hỗ trợ S3/CloudFront."_

  ![IAM - Đặt tên vai trò](/images/1-iam-role/get-student/iam-role-get-student-09.png)
  *Hình 9: Nhập tên và mô tả vai trò.*

- Kiểm tra lại:
  - **Trusted entity**: AWS Service (Lambda).
  - **Permissions**: `AWSLambdaBasicExecutionRole`, `AmazonDynamoDBReadOnlyAccess`, `AmazonS3FullAccess`, `CloudFrontFullAccess`.
- Nhấn **Create Role (Tạo Vai trò)**.

  ![IAM - Xác nhận tạo vai trò](/images/1-iam-role/get-student/iam-role-get-student-10.png)
  *Hình 10: Nút Create Role để xác nhận.*

### 7. Kiểm Tra Trạng Thái Tạo Vai Trò
- Sau khi nhấn **Create Role**, bạn sẽ trở về danh sách **Roles**.
- Tìm vai trò **LambdaGetStudentRole**. Nếu thành công, bạn sẽ thấy thông báo: _"Role LambdaGetStudentRole created"_.
- Nhấp vào **LambdaGetStudentRole** để xem chi tiết:
  - **ARN**: Ghi lại ARN (ví dụ: `arn:aws:iam::your-account-id:role/LambdaGetStudentRole`) để sử dụng khi cấu hình hàm Lambda.
  - **Policies**: Xác minh có `AWSLambdaBasicExecutionRole`, `AmazonDynamoDBReadOnlyAccess`, `AmazonS3FullAccess`, `CloudFrontFullAccess`.
- Nếu vai trò không xuất hiện, làm mới trang hoặc kiểm tra lại các bước.

  ![IAM - Chi tiết vai trò](/images/1-iam-role/get-student/iam-role-get-student-11.png)
  *Hình 11: Chi tiết vai trò LambdaGetStudentRole với ARN và policies.*

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Tên vai trò** | Phải là `LambdaGetStudentRole` (phân biệt chữ hoa/thường) để khớp với hàm Lambda. Tên sai sẽ gây lỗi khi thực thi. |
| **S3 và CloudFront** | `AmazonS3FullAccess` và `CloudFrontFullAccess` không được sử dụng hiện tại nhưng giữ lại cho các tính năng mở rộng (ví dụ: lưu tệp vào S3 hoặc quản lý CloudFront). Xóa nếu không cần để tuân thủ **least privilege**. |
| **Tối ưu hóa bảo mật** | Cân nhắc tạo chính sách tùy chỉnh thay vì `AmazonDynamoDBReadOnlyAccess` để giới hạn quyền chỉ trên bảng `studentData`. |
| **Kiểm tra sớm** | Ghi lại **ARN** và kiểm tra vai trò trong IAM trước khi cấu hình hàm Lambda để đảm bảo hoạt động đúng. |
| **Xử lý lỗi** | Nếu gặp lỗi "Access Denied", kiểm tra quyền tài khoản AWS (`iam:CreateRole`) hoặc liên hệ quản trị viên. |

> **Mẹo thực tiễn**: Kiểm tra ARN và chính sách ngay sau khi tạo vai trò để xác minh cấu hình trước khi tích hợp với Lambda.

---

## Kết Luận

Vai trò IAM **LambdaGetStudentRole** đảm bảo hàm Lambda `getStudentData` có quyền **đọc dữ liệu** từ DynamoDB, **ghi log** vào CloudWatch, và hỗ trợ mở rộng với S3 và CloudFront. Vai trò này sẵn sàng tích hợp vào hàm Lambda trong các bước tiếp theo.

> **Bước tiếp theo**: Chuyển đến [Tạo IAM Role cho Lambda Post](/2-Prerequiste/2.2-create-iam-role-for-lambda-post/) để thiết lập vai trò cho hàm lưu trữ dữ liệu sinh viên!