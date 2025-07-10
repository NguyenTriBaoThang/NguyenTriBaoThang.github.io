---
title: "Tạo Resource và Method cho Backup dữ liệu"
date: 2025-07-09
weight: 6
chapter: false
pre: "<b>4.6. </b>"
---

> **Mục tiêu**: Tạo resource `/backup` và phương thức **POST** trong API `student` (tạo ở mục 4.1) để tích hợp với hàm Lambda `BackupDynamoDBAndSendEmail` (tạo ở mục 3.3), cho phép sao lưu toàn bộ dữ liệu từ bảng DynamoDB `studentData` vào bucket S3 `student-backup-20250706` và gửi email thông báo qua SES. Phương thức sẽ yêu cầu API Key (`StudentApiKey`, tạo ở mục 4.2) trong header `x-api-key` để bảo mật, và chuẩn bị cho việc kích hoạt CORS (mục 4.7) để giao diện web (chạy trên CloudFront) có thể gửi yêu cầu.

---

## Tổng Quan về Resource và Phương Thức POST

- Resource `/backup` và phương thức **POST /backup** sẽ gọi hàm Lambda `BackupDynamoDBAndSendEmail` để:  
  - Sao lưu tất cả bản ghi từ bảng DynamoDB `studentData` (các trường: `studentid`, `name`, `class`, `birthdate`, `email`) vào tệp JSON trong bucket S3 `student-backup-20250706`.  
  - Gửi email thông báo qua SES đến một địa chỉ được chỉ định (ví dụ: admin hoặc người dùng).  
- Hàm `BackupDynamoDBAndSendEmail` trả về phản hồi JSON với header `Access-Control-Allow-Origin: '*'` để hỗ trợ CORS, phù hợp với giao diện web.  
- **API Key Required** đảm bảo chỉ các yêu cầu có `StudentApiKey` hợp lệ mới được xử lý.  
- Sau khi tạo, API cần được triển khai (mục 4.8) để phương thức **POST** có hiệu lực.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành mục 4.1 (tạo API `student`), mục 4.2 (tạo API Key `StudentApiKey`), mục 4.3 (tạo Usage Plan `StudentUsagePlan`), mục 4.4 (tạo phương thức **GET /students**), mục 4.5 (tạo phương thức **POST /students**), và mục 3 (tạo các hàm Lambda `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, SES email xác minh). Đảm bảo tài khoản AWS đã sẵn sàng và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console**  
   - Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS của bạn.  
   - Trong thanh tìm kiếm ở đầu trang, nhập **API Gateway** và chọn dịch vụ **Amazon API Gateway** để vào giao diện quản lý.  
   - Kiểm tra vùng AWS: Đảm bảo bạn đang làm việc trong vùng AWS chính (giả định `us-east-1` để đồng bộ với các mục trước), kiểm tra vùng ở góc trên bên phải AWS Console. Vùng này phải khớp với API `student`, hàm Lambda `BackupDynamoDBAndSendEmail`, bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, và SES.  

     ![Giao diện AWS Console với thanh tìm kiếm API Gateway.](/images/5-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/creating-a-backup-resource-and-method-01.png)
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm API Gateway.*

2. **Điều Hướng Đến Mục APIs**  
   - Trong giao diện chính của Amazon API Gateway, nhìn vào menu điều hướng bên trái.  
   - Chọn **APIs** để xem danh sách các API hiện có.  
   - Danh sách sẽ hiển thị API `student` (tạo ở mục 4.1). Nếu không thấy, kiểm tra lại vùng AWS hoặc làm mới trang.  

     ![Menu điều hướng với tùy chọn APIs.](/images/5-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/creating-a-backup-resource-and-method-02.png)
     *Hình 2: Menu điều hướng với tùy chọn APIs.*

3. **Chọn API student**  
   - Trong danh sách **APIs**, tìm và chọn API có tên `student`.  
   - Bạn sẽ được chuyển đến trang quản lý API `student`, hiển thị các mục như **Resources**, **Stages**, **API Keys**, v.v.  
   - Chọn **Resources** từ menu bên trái để bắt đầu cấu hình resource và method.  

     ![Trang quản lý API student với tùy chọn Resources.](/images/5-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/creating-a-backup-resource-and-method-03.png)
     *Hình 3: Trang quản lý API student với tùy chọn Resources.*

4. **Tạo Resource /backup**  
   - Trong giao diện **Resources**, bạn sẽ thấy cây tài nguyên với gốc là `/` và resource `/students` (tạo ở mục 4.4).  
   - Nhấn **Actions** > **Create Resource** để tạo resource mới.  
   - Cấu hình resource:  
     - **Resource Name**: Nhập `backup`.  
     - **Resource Path**: Nhập `/backup` (hoặc để mặc định, sẽ tự động là `/backup`).  
     - **Enable API Gateway CORS**: Chọn để chuẩn bị cho việc kích hoạt CORS (mục 4.7).  
   - Nhấn **Create Resource** để tạo.  
   - Kiểm tra: Resource `/backup` sẽ xuất hiện dưới gốc `/` trong cây tài nguyên.  

     ![Nhấn nút Create.](/images/5-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/creating-a-backup-resource-and-method-04.png)
     *Hình 4: Nhấn nút Create.*  

     ![Giao diện cấu hình resource /backup.](/images/5-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/creating-a-backup-resource-and-method-05.png)
     *Hình 5: Giao diện cấu hình resource /backup.*

5. **Tạo Phương Thức POST**  
   - Trong cây tài nguyên, chọn resource `/backup`.  
   - Nhấn **Actions** > **Create Method**.  
   - Trong dropdown dưới `/backup`, chọn **POST** và nhấn biểu tượng check (✔) để xác nhận.  
   - **Lưu ý**: Nếu dropdown không hiển thị **POST**, đảm bảo bạn đã chọn đúng resource `/backup`.  

     ![Giao diện tạo phương thức POST.](/images/5-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/creating-a-backup-resource-and-method-06.png)
     - *Hình 6: Giao diện tạo phương thức POST.*

6. **Cấu Hình Tích Hợp Lambda**  
   - Trong giao diện cấu hình phương thức **POST**:  
     - **Integration Type**: Chọn **Lambda Function** để tích hợp với hàm Lambda.  
     - **Use Lambda Proxy integration**: Chọn (để gửi toàn bộ yêu cầu HTTP, bao gồm headers và body, đến hàm Lambda và nhận phản hồi JSON với headers).  
     - **Lambda Region**: Chọn `us-east-1` (hoặc vùng AWS của bạn, phải khớp với vùng của hàm `BackupDynamoDBAndSendEmail`).  
     - **Lambda Function**: Nhập `BackupDynamoDBAndSendEmail`.  
       - **Lưu ý**: Nếu hàm `BackupDynamoDBAndSendEmail` không xuất hiện trong danh sách gợi ý, nhập thủ công và đảm bảo hàm tồn tại trong Lambda (mục 3.3).  
     - Nhấn **Save** để lưu cấu hình.  
   - Nếu AWS yêu cầu cấp quyền, nhấn **OK** để cho phép API Gateway gọi hàm Lambda `BackupDynamoDBAndSendEmail`. AWS sẽ tự động thêm chính sách IAM vào vai trò của hàm Lambda (thường là `DynamoDBBackupRole` từ mục 3.3) với quyền `lambda:InvokeFunction`.  

     ![Giao diện cấu hình tích hợp Lambda.](/images/5-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/creating-a-backup-resource-and-method-07.png)
     - *Hình 7: Giao diện cấu hình tích hợp Lambda.*  

     ![Nhấn nút Save sau khi cấu hình.](/images/5-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/creating-a-backup-resource-and-method-08.png)
     - *Hình 8: Nhấn nút Save sau khi cấu hình.*

7. **Bật API Key Required**  
   - Trong giao diện **Method Request** của **POST /backup**:  
     - Nhấn **Edit** bên cạnh **Authorization**.  
     - Chọn **NONE** (API Key sẽ xử lý xác thực, không cần Cognito hoặc IAM Authorizer).  
     - Trong **API Key Required**, chọn **true** để yêu cầu API Key trong header `x-api-key`.  
       - **Giải thích**: Điều này đảm bảo mọi yêu cầu gửi đến **POST /backup** phải chứa `StudentApiKey` (tạo ở mục 4.2) trong header `x-api-key`.  
     - Nhấn **Save** hoặc biểu tượng check (✔) để lưu cấu hình.  

     ![Giao diện bật API Key Required.](/images/5-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/creating-a-backup-resource-and-method-09.png)
     - *Hình 9: Giao diện bật API Key Required.*

8. **Kiểm Tra Trạng Thái Tạo Phương Thức**  
   - Sau khi cấu hình và nhấn **Save**, bạn sẽ thấy thông báo: _"Successfully created method ‘POST’. Redeploy your API for the update to take effect."_  
   - **Lưu ý quan trọng**: Phương thức **POST** sẽ không hoạt động cho đến khi bạn triển khai API vào một stage (mục 4.8).  
   - Để kiểm tra cấu hình:  
     - Trong **Resources**, chọn **POST** dưới `/backup`.  
     - Xác minh:  
       - **Integration Request**: Hiển thị **Lambda Function: BackupDynamoDBAndSendEmail**.  
       - **Method Request**: **API Key Required: true**.  
     - Nếu gặp lỗi:  
       - _"Lambda function not found"_: Kiểm tra hàm `BackupDynamoDBAndSendEmail` tồn tại trong **Lambda** > **Functions** và vùng AWS khớp (`us-east-1`).  
       - _"AccessDenied"_: Kiểm tra vai trò IAM của tài khoản AWS có quyền `apigateway:PUT` để tạo method.  
       - _"Permission denied"_: Đảm bảo API Gateway có quyền gọi `BackupDynamoDBAndSendEmail` (AWS tự động thêm quyền khi bạn nhấn **OK**).  

     ![Thông báo thành công sau khi tạo phương thức POST.](/images/5-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/creating-a-backup-resource-and-method-10.png)
     - *Hình 10: Thông báo thành công sau khi tạo phương thức POST.*

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Tích hợp Lambda Proxy** | **Lambda Proxy integration** cho phép gửi toàn bộ yêu cầu HTTP (headers, body) đến hàm `BackupDynamoDBAndSendEmail` và nhận phản hồi JSON với headers (như `Access-Control-Allow-Origin: '*'`). <br> Đảm bảo mã của `BackupDynamoDBAndSendEmail` (mục 3.3) xử lý sao lưu và gửi email đúng cách. |
| **Bảo mật API Key** | Với **API Key Required: true**, yêu cầu gửi đến **POST /backup** phải chứa header `x-api-key: <StudentApiKey>`. <br> Để tăng cường bảo mật, lưu API Key trong **AWS Secrets Manager** (xem mục 4.2). |
| **CORS** | Phương thức **POST** cần hỗ trợ CORS để giao diện web có thể gửi yêu cầu cross-origin. Điều này sẽ được cấu hình chi tiết ở mục 4.7 (kích hoạt CORS với phương thức **OPTIONS**). <br> Đảm bảo hàm `BackupDynamoDBAndSendEmail` trả về header `Access-Control-Allow-Origin: '*'` (hoặc domain CloudFront cụ thể, ví dụ: `https://d12345678.cloudfront.net`). |
| **Vùng AWS** | Đảm bảo vùng `us-east-1` khớp với hàm `BackupDynamoDBAndSendEmail`, bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, SES, và API `student`. Nếu sử dụng vùng khác (ví dụ: `us-west-2`), chọn đúng vùng trong **Lambda Region**. |
| **Xử lý lỗi** | - Nếu gặp lỗi _"Lambda function not found"_: <br> - Kiểm tra hàm `BackupDynamoDBAndSendEmail` tồn tại trong **Lambda** > **Functions**. <br> - Đảm bảo vùng AWS khớp (`us-east-1`). <br> - Nếu gặp lỗi `403 "Forbidden"` khi gọi API (sau khi deploy): <br> - Kiểm tra **API Key Required: true** và API Key `StudentApiKey` hợp lệ. <br> - Đảm bảo API Key được liên kết với Usage Plan (mục 4.3, 4.9). <br> - Nếu gặp lỗi `500` từ Lambda, kiểm tra log trong **CloudWatch** (log group `/aws/lambda/BackupDynamoDBAndSendEmail`) để gỡ lỗi: <br> - `NoSuchBucket`: Kiểm tra bucket S3 `student-backup-20250706` tồn tại. <br> - `AccessDenied`: Kiểm tra vai trò `DynamoDBBackupRole` có quyền `s3:PutObject`, `dynamodb:Scan`, và `ses:SendEmail`. <br> - `Email address not verified`: Kiểm tra email nguồn (`no-reply@system.edu.vn`) và email nhận (`admin@system.edu.vn`) đã được xác minh trong SES (mục 2.5). |
| **Tối ưu hóa** | - Thêm header `Access-Control-Allow-Origin` trong **Method Response** để đảm bảo CORS hoạt động đúng: <br> - Trong **Method Response** của **POST /backup**, thêm **Status Code 200, 500** với header `Access-Control-Allow-Origin: '*'`. <br> - Trong **Integration Response**, ánh xạ phản hồi từ Lambda để xử lý các mã trạng thái. <br> - Cân nhắc sử dụng **AWS WAF** với API Gateway để bảo vệ khỏi các cuộc tấn công DDoS hoặc lạm dụng API Key. <br> - Nếu bảng `studentData` lớn, đảm bảo hàm `BackupDynamoDBAndSendEmail` xử lý phân trang cho Scan (ví dụ: sử dụng `LastEvaluatedKey`) để tránh vượt giới hạn. |
| **Kiểm tra sớm** | - Sau khi tạo phương thức **POST**, xác minh cấu hình trong **Resources** > **POST /backup** (**Integration Request**, **Method Request**). <br> - Sau khi deploy API (mục 4.8), kiểm tra phương thức **POST** bằng Postman hoặc curl. <br> - Kiểm tra bucket S3 `student-backup-20250706` (vào **S3** > **Buckets** > `student-backup-20250706` > **Objects**) để xác minh tệp backup (ví dụ: `backup-20250707-124500.json`). <br> - Kiểm tra hộp thư (bao gồm Spam/Junk) của email nhận (ví dụ: `admin@system.edu.vn`) để xác minh email thông báo từ SES. <br> - Nếu nhận lỗi `403 "Forbidden"`, kiểm tra API Key và cấu hình **API Key Required**. <br> - Nếu nhận lỗi `500`, kiểm tra log **CloudWatch** của hàm `BackupDynamoDBAndSendEmail`. |
| **Kiểm tra tích hợp với giao diện web** | Sau khi deploy API (mục 4.8) và liên kết Usage Plan (mục 4.9), sử dụng API Key trong giao diện web (sử dụng Tailwind CSS, chạy trên CloudFront) để gọi endpoint **POST /backup**. |

> **Mẹo thực tiễn**: Xác minh cấu hình **Integration Request** và **API Key Required** trước khi triển khai API. Kiểm tra tệp backup trong bucket S3 `student-backup-20250706` và email thông báo từ SES bằng Postman để đảm bảo hàm `BackupDynamoDBAndSendEmail` hoạt động đúng.

---

## Kết Luận

Resource `/backup` và phương thức **POST /backup** đã được tạo thành công trong API `student`, tích hợp với hàm Lambda `BackupDynamoDBAndSendEmail` và yêu cầu API Key `StudentApiKey`, sẵn sàng để triển khai và sử dụng trong giao diện web.

> **Bước tiếp theo**: Chuyển đến [Kích hoạt CORS để hỗ trợ giao diện web](/4-creating-a-restful-api/4.7-enabling-cors/) để tiếp tục!