---
title: "Kích hoạt CORS để hỗ trợ frontend truy cập"
date: 2023-10-25
weight: 7
chapter: false
pre: "<b>4.7 </b>"
---

# Kích Hoạt CORS Để Hỗ Trợ Frontend Truy Cập

> **Mục tiêu**: Kích hoạt CORS (Cross-Origin Resource Sharing) trên API `student` (tạo ở mục 4.1) để cho phép giao diện web (chạy trên CloudFront, sử dụng Tailwind CSS) gửi yêu cầu đến các endpoint **GET /students**, **POST /students**, và **POST /backup**. CORS sẽ được cấu hình trên các resource `/students` và `/backup` bằng cách thêm phương thức **OPTIONS** và thiết lập các header cần thiết (`Access-Control-Allow-Methods`, `Access-Control-Allow-Headers`, `Access-Control-Allow-Origin`), đảm bảo tích hợp mượt mà và an toàn với frontend.

---

## Tổng Quan về CORS trong API Gateway

- CORS là cơ chế bảo mật của trình duyệt, yêu cầu server (API Gateway) cho phép các yêu cầu cross-origin từ domain khác (ví dụ: `https://d12345678.cloudfront.net`) so với domain của API (ví dụ: `https://api-id.execute-api.us-east-1.amazonaws.com`).  
- Trong hệ thống này, CORS cần được kích hoạt cho các resource `/students` (**GET**, **POST**) và `/backup` (**POST**) để giao diện web có thể:  
  - Gửi yêu cầu **GET /students** để lấy danh sách sinh viên (hàm `getStudentData`, mục 4.4).  
  - Gửi yêu cầu **POST /students** để lưu thông tin sinh viên (hàm `insertStudentData`, mục 4.5).  
  - Gửi yêu cầu **POST /backup** để sao lưu dữ liệu (hàm `BackupDynamoDBAndSendEmail`, mục 4.6).  
- Kích hoạt CORS yêu cầu:  
  - Thêm phương thức **OPTIONS** cho mỗi resource để xử lý yêu cầu preflight từ trình duyệt.  
  - Thiết lập các header CORS (`Access-Control-Allow-Origin`, `Access-Control-Allow-Methods`, `Access-Control-Allow-Headers`) trong phản hồi của **OPTIONS**, **GET**, và **POST**.  
  - Đảm bảo các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`) trả về header `Access-Control-Allow-Origin: '*'`.  
- Sau khi kích hoạt CORS, API cần được triển khai (mục 4.8) để các thay đổi có hiệu lực.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành mục 4.1 (tạo API `student`), mục 4.2 (tạo API Key `StudentApiKey`), mục 4.3 (tạo Usage Plan `StudentUsagePlan`), mục 4.4 (tạo phương thức **GET /students**), mục 4.5 (tạo phương thức **POST /students**), mục 4.6 (tạo resource `/backup` và phương thức **POST /backup**), và mục 3 (tạo các hàm Lambda `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, SES email xác minh). Đảm bảo tài khoản AWS đã sẵn sàng và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console**  
   - Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS của bạn.  
   - Trong thanh tìm kiếm ở đầu trang, nhập **API Gateway** và chọn dịch vụ **Amazon API Gateway** để vào giao diện quản lý.  
   - Kiểm tra vùng AWS: Đảm bảo bạn đang làm việc trong vùng AWS chính (giả định `us-east-1` để đồng bộ với các mục trước), kiểm tra vùng ở góc trên bên phải AWS Console. Vùng này phải khớp với API `student`, các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`), bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, và SES.  

     ![Giao diện AWS Console với thanh tìm kiếm API Gateway.](/images/5-creating-a-restful-api/4.7-enabling-cors/enabling-cors-01.png)
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm API Gateway.*

2. **Điều Hướng Đến Mục APIs**  
   - Trong giao diện chính của Amazon API Gateway, nhìn vào menu điều hướng bên trái.  
   - Chọn **APIs** để xem danh sách các API hiện có.  
   - Danh sách sẽ hiển thị API `student` (tạo ở mục 4.1). Nếu không thấy, kiểm tra lại vùng AWS hoặc làm mới trang.  

     ![Menu điều hướng với tùy chọn APIs.](/images/5-creating-a-restful-api/4.7-enabling-cors/enabling-cors-02.png)
     *Hình 2: Menu điều hướng với tùy chọn APIs.*

3. **Chọn API student**  
   - Trong danh sách **APIs**, tìm và chọn API có tên `student`.  
   - Bạn sẽ được chuyển đến trang quản lý API `student`, hiển thị các mục như **Resources**, **Stages**, **API Keys**, v.v.  
   - Chọn **Resources** từ menu bên trái để bắt đầu cấu hình CORS.  

     ![Trang quản lý API student với tùy chọn Resources.](/images/5-creating-a-restful-api/4.7-enabling-cors/enabling-cors-03.png)
     *Hình 3: Trang quản lý API student với tùy chọn Resources.*

4. **Kích Hoạt CORS cho Resource /students**  
   - Trong giao diện **Resources**, bạn sẽ thấy cây tài nguyên với gốc là `/` và resource `/students` (tạo ở mục 4.4).  
   - Chọn resource `/students`.  
   - Nhấn **Actions** > **Enable CORS**.  
   - Trong giao diện **Enable CORS**:  
     - **Access-Control-Allow-Methods**: Chọn **GET**, **POST**, và **OPTIONS**.  
       - **Giải thích**:  
         - **GET** và **POST** tương ứng với các phương thức đã tạo (mục 4.4, 4.5).  
         - **OPTIONS** là phương thức preflight mà trình duyệt gửi để kiểm tra CORS trước khi gửi yêu cầu thực tế (**GET** hoặc **POST**).  
     - **Access-Control-Allow-Headers**: Giữ mặc định hoặc đảm bảo bao gồm `Content-Type`, `x-api-key` (do các phương thức yêu cầu API Key trong header `x-api-key`, mục 4.4, 4.5).  
       - Ví dụ: `Content-Type,x-api-key,Authorization`.  
     - **Access-Control-Allow-Origin**: Nhập `'*'` (cho phép mọi domain) hoặc domain CloudFront cụ thể (ví dụ: `https://d12345678.cloudfront.net`) để tăng cường bảo mật.  
     - **Access-Control-Max-Age**: Giữ mặc định (600 giây) để trình duyệt lưu cache phản hồi preflight.  
   - Nhấn **Enable CORS and replace existing CORS headers** để áp dụng.  
   - AWS sẽ tự động:  
     - Tạo phương thức **OPTIONS** cho resource `/students`.  
     - Cấu hình **Mock Integration** cho **OPTIONS** với phản hồi chứa các header CORS cần thiết.  
     - Cập nhật **Method Response** của **GET** và **POST** để bao gồm header `Access-Control-Allow-Origin`.  
   - Nhấn **Save** để lưu cấu hình.  

     ![Giao diện kích hoạt CORS cho resource /students.](/images/5-creating-a-restful-api/4.7-enabling-cors/enabling-cors-04.png)
     *Hình 4: Giao diện kích hoạt CORS cho resource /students.*

5. **Kích Hoạt CORS cho Resource /backup**  
   - Trong giao diện **Resources**, chọn resource `/backup` (tạo ở mục 4.6).  
   - Nhấn **Actions** > **Enable CORS**.  
   - Trong giao diện **Enable CORS**:  
     - **Access-Control-Allow-Methods**: Chọn **POST**, **OPTIONS**.  
       - **Giải thích**:  
         - **POST** tương ứng với phương thức đã tạo (mục 4.6).  
         - **OPTIONS** xử lý yêu cầu preflight cho `/backup`.  
     - **Access-Control-Allow-Headers**: Đảm bảo bao gồm `Content-Type`, `x-api-key`.  
     - **Access-Control-Allow-Origin**: Nhập `'*'` hoặc domain CloudFront cụ thể (ví dụ: `https://d12345678.cloudfront.net`).  
     - **Access-Control-Max-Age**: Giữ mặc định (600 giây).  
   - Nhấn **Enable CORS and replace existing CORS headers** để áp dụng.  
   - AWS sẽ tự động tạo phương thức **OPTIONS** cho `/backup` và cập nhật **Method Response** của **POST**.  
   - Nhấn **Save** để lưu cấu hình.  

     ![Giao diện kích hoạt CORS cho resource /backup.](/images/5-creating-a-restful-api/4.7-enabling-cors/enabling-cors-05.png)
     *Hình 5: Giao diện kích hoạt CORS cho resource /backup.*

6. **Kiểm Tra Trạng Thái Kích Hoạt CORS**  
   - Sau khi kích hoạt CORS, bạn sẽ thấy thông báo: _"Successfully enabled CORS"_ cho từng resource (`/students`, `/backup`).  
   - Để kiểm tra cấu hình:  
     - Trong **Resources**, chọn resource `/students`:  
       - Xác minh phương thức **OPTIONS** xuất hiện với **Mock Integration**.  
       - Trong **Method Response** của **GET**, **POST**, và **OPTIONS**, kiểm tra header `Access-Control-Allow-Origin: '*'`.  
       - Trong **Integration Response** của **OPTIONS**, kiểm tra phản hồi trả về:  
         ```json
         {
             "Access-Control-Allow-Origin": "*",
             "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
             "Access-Control-Allow-Headers": "Content-Type,x-api-key,Authorization"
         }
         ```  
     - Lặp lại kiểm tra cho resource `/backup` (chỉ có **POST** và **OPTIONS**).  
   - Nếu gặp lỗi:  
     - _"CORS headers already exist"_: Chọn **Replace existing CORS headers** để ghi đè.  
     - _"AccessDenied"_: Kiểm tra vai trò IAM của tài khoản AWS có quyền `apigateway:PUT` để chỉnh sửa method.  
     - _"OPTIONS method not found"_: Đảm bảo bạn đã nhấn **Enable CORS** đúng cách.  
   - **Lưu ý quan trọng**: CORS sẽ không hoạt động cho đến khi bạn triển khai API vào một stage (mục 4.8).  

     ![Thông báo thành công sau khi kích hoạt CORS.](/images/5-creating-a-restful-api/4.7-enabling-cors/enabling-cors-06.png)
     *Hình 6: Thông báo thành công sau khi kích hoạt CORS.*

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Cấu hình CORS chính xác** | - **Access-Control-Allow-Origin**: Sử dụng `'*'` cho phép mọi domain (phù hợp khi thử nghiệm). Trong môi trường production, chỉ định domain CloudFront cụ thể (ví dụ: `https://d12345678.cloudfront.net`) để tăng bảo mật. <br> - **Access-Control-Allow-Headers**: Đảm bảo bao gồm `x-api-key` vì các phương thức yêu cầu API Key (`StudentApiKey`, mục 4.2). <br> - **Access-Control-Allow-Methods**: Bao gồm **OPTIONS** để xử lý yêu cầu preflight. |
| **Tích hợp với Lambda** | Các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`) phải trả về header `Access-Control-Allow-Origin: '*'` trong phản hồi để tránh lỗi CORS. Đã được cấu hình trong mã Lambda ở các mục 3.1, 3.2, 3.3. |
| **Bảo mật API Key** | Yêu cầu gửi đến các endpoint (**GET /students**, **POST /students**, **POST /backup**) phải chứa header `x-api-key: <StudentApiKey>`. <br> Lưu API Key trong **AWS Secrets Manager** để tăng cường bảo mật (xem mục 4.2). |
| **Vùng AWS** | Đảm bảo vùng `us-east-1` khớp với API `student`, các hàm Lambda, bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, và SES. |
| **Xử lý lỗi** | - Nếu giao diện web báo lỗi CORS (ví dụ: _"No 'Access-Control-Allow-Origin' header"_): <br> - Kiểm tra **Method Response** của **GET**, **POST**, và **OPTIONS** có header `Access-Control-Allow-Origin`. <br> - Kiểm tra **Integration Response** của **OPTIONS** trả về đúng headers CORS. <br> - Đảm bảo các hàm Lambda trả về `Access-Control-Allow-Origin: '*'`. <br> - Nếu gặp lỗi `403 "Forbidden"` khi gọi API: <br> - Kiểm tra API Key `StudentApiKey` hợp lệ và được liên kết với Usage Plan (mục 4.3, 4.9). <br> - Đảm bảo **API Key Required: true** trong **Method Request** (mục 4.4, 4.5, 4.6). <br> - Nếu gặp lỗi `500` từ Lambda, kiểm tra log trong **CloudWatch** (log groups `/aws/lambda/getStudentData`, `/aws/lambda/insertStudentData`, `/aws/lambda/BackupDynamoDBAndSendEmail`). |
| **Tối ưu hóa** | - Chỉ định domain CloudFront cụ thể trong `Access-Control-Allow-Origin` thay vì `'*'` để tăng bảo mật. <br> - Cân nhắc sử dụng **AWS WAF** với API Gateway để bảo vệ khỏi các cuộc tấn công DDoS hoặc lạm dụng API Key. <br> - Nếu cần kiểm tra yêu cầu preflight chi tiết, bật **CloudWatch Logs** cho API Gateway: <br> - Trong **API Gateway** > **Settings** > **CloudWatch Logs**, chọn **Enable CloudWatch Logs** và đặt mức log (ví dụ: `INFO`). <br> - Thêm **Request Validator** cho **POST /students** và **POST /backup** để kiểm tra body JSON (xem mục 4.5). |
| **Kiểm tra sớm** | - Sau khi kích hoạt CORS, xác minh phương thức **OPTIONS** xuất hiện trong **Resources** cho `/students` và `/backup`. <br> - Sau khi deploy API (mục 4.8), kiểm tra CORS bằng cách gọi endpoint từ giao diện web hoặc sử dụng Postman/curl. <br> - Kiểm tra từ giao diện web (mở **Developer Tools** > **Network** trong trình duyệt) để xác minh không có lỗi CORS khi gọi **GET /students**, **POST /students**, hoặc **POST /backup**. <br> - Nếu nhận lỗi CORS, kiểm tra headers trong **Method Response** và **Integration Response**, hoặc log **CloudWatch** của API Gateway. |
| **Kiểm tra tích hợp với giao diện web** | Sau khi deploy API (mục 4.8) và liên kết Usage Plan (mục 4.9), gọi các endpoint (**GET /students**, **POST /students**, **POST /backup**) từ giao diện web (sử dụng Tailwind CSS, chạy trên CloudFront). |

> **Mẹo thực tiễn**: Xác minh cấu hình **Method Response** và **Integration Response** của **OPTIONS** trước khi triển khai API. Kiểm tra các endpoint từ giao diện web bằng **Developer Tools** để đảm bảo không có lỗi CORS và dữ liệu được trả về đúng.

---

## Kết Luận

CORS đã được kích hoạt thành công trên các resource `/students` và `/backup` trong API `student`, cho phép giao diện web gọi các endpoint **GET /students**, **POST /students**, và **POST /backup** mà không gặp lỗi CORS.

> **Bước tiếp theo**: Chuyển đến [Triển khai API để sử dụng thực tế](/4-creating-a-restful-api/4.8-deploying-api/) để tiếp tục!