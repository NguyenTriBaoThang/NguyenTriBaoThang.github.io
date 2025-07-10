---
title: "Triển khai API lên một Stage cụ thể"
date: 2025-07-09
weight: 8
chapter: false
pre: "<b>4.8. </b>"
---

> **Mục tiêu**: Triển khai API `student` (tạo ở mục 4.1) lên stage `prod` trong AWS API Gateway để kích hoạt các phương thức **GET /students** (mục 4.4), **POST /students** (mục 4.5), và **POST /backup** (mục 4.6), cùng với cấu hình CORS (mục 4.7). Sau khi triển khai, sao chép **Invoke URL** (ví dụ: `https://abc123.execute-api.us-east-1.amazonaws.com/prod`) để sử dụng trong giao diện web (chạy trên CloudFront, sử dụng Tailwind CSS) khi gọi các endpoint với API Key `StudentApiKey` (mục 4.2).

---

## Tổng Quan về Triển Khai API trong API Gateway

- Stage là một môi trường triển khai (ví dụ: `prod`, `dev`, `test`) trong API Gateway, đại diện cho phiên bản hoạt động của API tại một thời điểm.  
- Triển khai API lên stage `prod` sẽ:  
  - Kích hoạt các phương thức **GET /students**, **POST /students**, và **POST /backup**, tích hợp với các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`).  
  - Áp dụng cấu hình CORS (mục 4.7) để giao diện web gửi yêu cầu cross-origin.  
  - Yêu cầu API Key `StudentApiKey` trong header `x-api-key` cho các phương thức (do bật **API Key Required** ở mục 4.4, 4.5, 4.6).  
- **Invoke URL** là URL gốc của stage (ví dụ: `https://abc123.execute-api.us-east-1.amazonaws.com/prod`), được kết hợp với các resource path (`/students`, `/backup`) để tạo endpoint hoàn chỉnh:  
  - **GET** `https://abc123.execute-api.us-east-1.amazonaws.com/prod/students`  
  - **POST** `https://abc123.execute-api.us-east-1.amazonaws.com/prod/students`  
  - **POST** `https://abc123.execute-api.us-east-1.amazonaws.com/prod/backup`  
- Sau khi triển khai, **Invoke URL** sẽ được sử dụng trong giao diện web để gọi API với API Key.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành mục 4.1 (tạo API `student`), mục 4.2 (tạo API Key `StudentApiKey`), mục 4.3 (tạo Usage Plan `StudentUsagePlan`), mục 4.4 (tạo phương thức **GET /students**), mục 4.5 (tạo phương thức **POST /students**), mục 4.6 (tạo resource `/backup` và phương thức **POST /backup**), mục 4.7 (kích hoạt CORS), và mục 3 (tạo các hàm Lambda `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, SES email xác minh). Đảm bảo tài khoản AWS đã sẵn sàng và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console**  
   - Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS của bạn.  
   - Trong thanh tìm kiếm ở đầu trang, nhập **API Gateway** và chọn dịch vụ **Amazon API Gateway** để vào giao diện quản lý.  
   - Kiểm tra vùng AWS: Đảm bảo bạn đang làm việc trong vùng AWS chính (giả định `us-east-1` để đồng bộ với các mục trước), kiểm tra vùng ở góc trên bên phải AWS Console. Vùng này phải khớp với API `student`, các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`), bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, và SES.  

     ![Giao diện AWS Console với thanh tìm kiếm API Gateway.](/images/5-creating-a-restful-api/4.8-deploying-the-api/deploying-the-api-01.png)
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm API Gateway.*

2. **Điều Hướng Đến Mục APIs**  
   - Trong giao diện chính của Amazon API Gateway, nhìn vào menu điều hướng bên trái.  
   - Chọn **APIs** để xem danh sách các API hiện có.  
   - Danh sách sẽ hiển thị API `student` (tạo ở mục 4.1). Nếu không thấy, kiểm tra lại vùng AWS hoặc làm mới trang.  

     ![Menu điều hướng với tùy chọn APIs.](/images/5-creating-a-restful-api/4.8-deploying-the-api/deploying-the-api-02.png)
     *Hình 2: Menu điều hướng với tùy chọn APIs.*

3. **Chọn API student**  
   - Trong danh sách **APIs**, tìm và chọn API có tên `student`.  
   - Bạn sẽ được chuyển đến trang quản lý API `student`, hiển thị các mục như **Resources**, **Stages**, **API Keys**, v.v.  

     ![Trang quản lý API student.](/images/5-creating-a-restful-api/4.8-deploying-the-api/deploying-the-api-03.png)
     *Hình 3: Trang quản lý API student.*

4. **Triển Khai API**  
   - Trong trang quản lý API `student`, chọn **Resources** từ menu bên trái.  
   - Nhấn **Actions** > **Deploy API** để mở giao diện triển khai.

    ![Nhấn vào nút Deploy API.](/images/5-creating-a-restful-api/4.8-deploying-the-api/deploying-the-api-04.png)
     *Hình 4: Nhấn vào nút Deploy API.*

   - Trong giao diện **Deploy API**:  
     - **Deployment stage**: Chọn **New Stage**.  
     - **Stage name**: Nhập `prod` (viết thường, không chứa ký tự đặc biệt).  
     - **Stage description**: (Tùy chọn) Nhập `Production stage for StudentManagementAPI` để mô tả rõ ràng mục đích.  
     - **Deployment description**: (Tùy chọn) Nhập `Initial deployment for prod stage` để ghi chú phiên bản triển khai.  
   - Nhấn **Deploy** để triển khai API lên stage `prod`.  
   - **Lưu ý**:  
     - Nếu stage `prod` đã tồn tại (từ lần triển khai trước), chọn `prod` trong dropdown **Deployment stage** thay vì tạo mới, rồi nhấn **Deploy** để cập nhật.  
     - Mỗi lần thay đổi cấu hình API (method, CORS, v.v.), bạn phải triển khai lại để áp dụng.  

     ![Giao diện triển khai API lên stage prod.](/images/5-creating-a-restful-api/4.8-deploying-the-api/deploying-the-api-05.png)
     *Hình 5: Giao diện triển khai API lên stage prod.*

5. **Kiểm Tra Trạng Thái Triển Khai**  
   - Sau khi nhấn **Deploy**, bạn sẽ thấy thông báo: _"Successfully created deployment for student. This deployment is active for prod."_  
   - Trong menu bên trái, chọn **Stages** để xem danh sách stage.  
   - Chọn stage `prod` để kiểm tra chi tiết:  
     - Xác minh **Invoke URL** hiển thị ở đầu trang (ví dụ: `https://abc123.execute-api.us-east-1.amazonaws.com/prod`).  
     - Kiểm tra các resource (`/students`, `/backup`) và phương thức (**GET**, **POST**, **OPTIONS**) đã được triển khai.  
   - Nếu không thấy thông báo hoặc gặp lỗi:  
     - _"AccessDenied"_: Kiểm tra vai trò IAM của tài khoản AWS có quyền `apigateway:POST` để triển khai API.  
     - _"Stage already exists"_: Nếu stage `prod` đã tồn tại, chọn stage hiện có và triển khai lại.  
     - _"No methods deployed"_: Đảm bảo các phương thức **GET /students**, **POST /students**, **POST /backup**, và **OPTIONS** đã được tạo (mục 4.4, 4.5, 4.6, 4.7).  

     ![Thông báo trạng thái triển khai và chi tiết stage prod.](/images/5-creating-a-restful-api/4.8-deploying-the-api/deploying-the-api-06.png)
     *Hình 6: Thông báo trạng thái triển khai và chi tiết stage prod.*

6. **Sao Chép Invoke URL**  
   - Trong **Stages** > `prod`, sao chép **Invoke URL** (ví dụ: `https://abc123.execute-api.us-east-1.amazonaws.com/prod`).  
   - Lưu **Invoke URL** ở nơi an toàn (ví dụ: tệp cấu hình, biến môi trường, hoặc **AWS Secrets Manager**) để sử dụng trong giao diện web.  
   - Sử dụng **Invoke URL**:  
     - Kết hợp **Invoke URL** với resource path để tạo endpoint hoàn chỉnh:  
       - **GET** `https://abc123.execute-api.us-east-1.amazonaws.com/prod/students`  
       - **POST** `https://abc123.execute-api.us-east-1.amazonaws.com/prod/students`  
       - **POST** `https://abc123.execute-api.us-east-1.amazonaws.com/prod/backup`  
     - Các endpoint này sẽ được gọi từ giao diện web với header `x-api-key: <StudentApiKey>`.  

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Bảo mật API Key** | Mỗi yêu cầu đến các endpoint phải chứa header `x-api-key` với giá trị `StudentApiKey` (tạo ở mục 4.2). <br> Lưu API Key trong **AWS Secrets Manager** để tăng cường bảo mật, tránh nhúng trực tiếp trong mã JavaScript. |
| **CORS** | Đảm bảo CORS đã được kích hoạt đúng cách (mục 4.7) với phương thức **OPTIONS** và header `Access-Control-Allow-Origin: '*'` (hoặc domain CloudFront cụ thể). <br> Các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`) phải trả về header `Access-Control-Allow-Origin: '*'` trong phản hồi (đã cấu hình ở mục 3.1, 3.2, 3.3). |
| **Vùng AWS** | Đảm bảo vùng `us-east-1` khớp với API `student`, các hàm Lambda, bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, và SES. |
| **Xử lý lỗi** | - Nếu gặp lỗi `403 "Forbidden"` khi gọi endpoint: <br> - Kiểm tra API Key `StudentApiKey` hợp lệ và được liên kết với Usage Plan (mục 4.3, 4.9). <br> - Đảm bảo **API Key Required: true** trong **Method Request** (mục 4.4, 4.5, 4.6). <br> - Nếu gặp lỗi `404 "Not Found"`: <br> - Kiểm tra **Invoke URL** đúng và resource path (`/students`, `/backup`) được cấu hình. <br> - Đảm bảo API đã được triển khai lên stage `prod`. <br> - Nếu gặp lỗi CORS: <br> - Kiểm tra cấu hình CORS (mục 4.7) và header `Access-Control-Allow-Origin` trong **Method Response** và Lambda. <br> - Nếu gặp lỗi `500` từ Lambda, kiểm tra log trong **CloudWatch** (log groups `/aws/lambda/getStudentData`, `/aws/lambda/insertStudentData`, `/aws/lambda/BackupDynamoDBAndSendEmail`). |
| **Tối ưu hóa** | - Bật **CloudWatch Logs** cho stage `prod` để theo dõi yêu cầu API: <br> - Trong **Stages** > `prod` > **Logs/Tracing**, chọn **Enable CloudWatch Logs** và đặt mức log (ví dụ: `INFO`). <br> - Kiểm tra log trong **CloudWatch** > **Log groups** > `/aws/apigateway/student-prod`. <br> - Cân nhắc sử dụng **AWS WAF** với API Gateway để bảo vệ khỏi các cuộc tấn công DDoS hoặc lạm dụng API Key. <br> - Nếu cần nhiều stage (ví dụ: `dev`, `test`), tạo thêm stage trong **Stages** và triển khai riêng biệt để thử nghiệm. |
| **Kiểm tra sớm** | - Sau khi triển khai, xác minh stage `prod` xuất hiện trong **Stages** với **Invoke URL** đúng. <br> - Kiểm tra các endpoint bằng Postman hoặc curl. <br> - Kết quả mong đợi: <br> - **GET /students**: Trả về danh sách sinh viên từ DynamoDB `studentData`. <br> - **POST /students**: Lưu bản ghi mới vào DynamoDB và gửi email xác nhận qua SES. <br> - **POST /backup**: Tạo tệp backup trong S3 `student-backup-20250706` và gửi email thông báo. <br> - Kiểm tra từ giao diện web (mở **Developer Tools** > **Network** trong trình duyệt) để xác minh không có lỗi CORS hoặc 403. <br> - Nếu nhận lỗi, kiểm tra API Key, cấu hình CORS, hoặc log **CloudWatch**. |
| **Kiểm tra tích hợp với giao diện web** | Sử dụng **Invoke URL** trong giao diện web để gọi các endpoint, đảm bảo header `x-api-key` được gửi đúng (sử dụng Tailwind CSS, chạy trên CloudFront). |

> **Mẹo thực tiễn**: Sau khi triển khai, kiểm tra **Invoke URL** bằng Postman trước khi tích hợp với giao diện web. Xác minh dữ liệu trong DynamoDB `studentData`, bucket S3 `student-backup-20250706`, và email SES để đảm bảo các endpoint hoạt động đúng.

---

## Kết Luận

API `student` đã được triển khai thành công lên stage `prod` với **Invoke URL** sẵn sàng để sử dụng trong giao diện web, hỗ trợ các phương thức **GET /students**, **POST /students**, và **POST /backup**.

> **Bước tiếp theo**: Chuyển đến [Liên kết API Key với Usage Plan](/4-creating-a-restful-api/4.9-linking-api-key-to-usage-plan/) để tiếp tục!