---
title: "Tạo phương thức POST để lưu dữ liệu"
date: 2023-10-25
weight: 5
chapter: false
pre: "<b>4.5. </b>"
---

> **Mục tiêu**: Tạo phương thức **POST** trên resource `/students` trong API `student` (tạo ở mục 4.1) để tích hợp với hàm Lambda `insertStudentData` (tạo ở mục 3.2), cho phép lưu thông tin sinh viên vào bảng DynamoDB `studentData` và gửi email xác nhận qua SES. Phương thức sẽ yêu cầu API Key (`StudentApiKey`, tạo ở mục 4.2) trong header `x-api-key` để bảo mật, và chuẩn bị cho việc kích hoạt CORS (mục 4.7) để giao diện web (chạy trên CloudFront) có thể gửi yêu cầu.

---

## Tổng Quan về Phương Thức POST

- Phương thức **POST /students** sẽ gọi hàm Lambda `insertStudentData` để lưu một bản ghi sinh viên (các trường: `studentid`, `name`, `class`, `birthdate`, `email`) vào bảng DynamoDB `studentData` và gửi email xác nhận qua SES.  
- Hàm `insertStudentData` trả về phản hồi JSON với header `Access-Control-Allow-Origin: '*'` để hỗ trợ CORS, phù hợp với giao diện web.  
- **API Key Required** đảm bảo chỉ các yêu cầu có `StudentApiKey` hợp lệ mới được xử lý.  
- Sau khi tạo, API cần được triển khai (mục 4.8) để phương thức **POST** có hiệu lực.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành mục 4.1 (tạo API `student`), mục 4.2 (tạo API Key `StudentApiKey`), mục 4.3 (tạo Usage Plan `StudentUsagePlan`), mục 4.4 (tạo phương thức **GET /students**), và mục 3 (tạo các hàm Lambda `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, SES email xác minh). Đảm bảo tài khoản AWS đã sẵn sàng và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console**  
   - Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS của bạn.  
   - Trong thanh tìm kiếm ở đầu trang, nhập **API Gateway** và chọn dịch vụ **Amazon API Gateway** để vào giao diện quản lý.  
   - Kiểm tra vùng AWS: Đảm bảo bạn đang làm việc trong vùng AWS chính (giả định `us-east-1` để đồng bộ với các mục trước), kiểm tra vùng ở góc trên bên phải AWS Console. Vùng này phải khớp với API `student`, hàm Lambda `insertStudentData`, bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, và SES.  

     ![Giao diện AWS Console với thanh tìm kiếm API Gateway.](/images/5-creating-a-restful-api/4.5-creating-a-post-method/creating-a-post-method-01.png)
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm API Gateway.*

2. **Điều Hướng Đến Mục APIs**  
   - Trong giao diện chính của Amazon API Gateway, nhìn vào menu điều hướng bên trái.  
   - Chọn **APIs** để xem danh sách các API hiện có.  
   - Danh sách sẽ hiển thị API `student` (tạo ở mục 4.1). Nếu không thấy, kiểm tra lại vùng AWS hoặc làm mới trang.  

     ![Menu điều hướng với tùy chọn APIs.](/images/5-creating-a-restful-api/4.5-creating-a-post-method/creating-a-post-method-02.png)
     *Hình 2: Menu điều hướng với tùy chọn APIs.*

3. **Chọn API student**  
   - Trong danh sách **APIs**, tìm và chọn API có tên `student`.  
   - Bạn sẽ được chuyển đến trang quản lý API `student`, hiển thị các mục như **Resources**, **Stages**, **API Keys**, v.v.  
   - Chọn **Resources** từ menu bên trái để tiếp tục cấu hình resource và method.  

     ![Trang quản lý API student với tùy chọn Resources.](/images/5-creating-a-restful-api/4.5-creating-a-post-method/creating-a-post-method-03.png)
     *Hình 3: Trang quản lý API student với tùy chọn Resources.*

4. **Sử Dụng Resource /students**  
   - Trong giao diện **Resources**, bạn sẽ thấy cây tài nguyên với gốc là `/` và resource `/students` (đã tạo ở mục 4.4 cho phương thức **GET**).  
   - Nếu resource `/students` chưa tồn tại:  
     - Nhấn **Actions** > **Create Resource**.  
     - Cấu hình resource:  
       - **Resource Name**: Nhập `students`.  
       - **Resource Path**: Nhập `/students` (hoặc để mặc định, sẽ tự động là `/students`).  
       - **Enable API Gateway CORS**: Chọn để chuẩn bị cho việc kích hoạt CORS (mục 4.7).  
     - Nhấn **Create Resource** để tạo.  
   - Chọn resource `/students` trong cây tài nguyên để tạo phương thức **POST**.  

     ![Giao diện sử dụng resource /students.](/images/5-creating-a-restful-api/4.5-creating-a-post-method/creating-a-post-method-04.png)
     *Hình 4: Giao diện sử dụng resource /students.*

5. **Tạo Phương Thức POST**  
   - Trong cây tài nguyên, chọn resource `/students`.  
   - Nhấn **Actions** > **Create Method**.  
   - Trong dropdown dưới `/students`, chọn **POST** và nhấn biểu tượng check (✔) để xác nhận.  
   - **Lưu ý**: Nếu dropdown không hiển thị **POST**, đảm bảo bạn đã chọn đúng resource `/students`.  
   - Trong giao diện cấu hình phương thức **POST**:  
     - **Integration Type**: Chọn **Lambda Function** để tích hợp với hàm Lambda.  
     - **Use Lambda Proxy integration**: Chọn (để gửi toàn bộ yêu cầu HTTP, bao gồm headers và body, đến hàm Lambda và nhận phản hồi JSON với headers).  
     - **Lambda Region**: Chọn `us-east-1` (hoặc vùng AWS của bạn, phải khớp với vùng của hàm `insertStudentData`).  
     - **Lambda Function**: Nhập `insertStudentData`.  
       - **Lưu ý**: Nếu hàm `insertStudentData` không xuất hiện trong danh sách gợi ý, nhập thủ công và đảm bảo hàm tồn tại trong Lambda (mục 3.2).  
     - Nhấn **Save** để lưu cấu hình.  
   - Nếu AWS yêu cầu cấp quyền, nhấn **OK** để cho phép API Gateway gọi hàm Lambda `insertStudentData`. AWS sẽ tự động thêm chính sách IAM vào vai trò của hàm Lambda (thường là `LambdaInsertStudentRole` từ mục 3.2) với quyền `lambda:InvokeFunction`.  

     ![Giao diện tạo phương thức POST.](/images/5-creating-a-restful-api/4.5-creating-a-post-method/creating-a-post-method-05.png)  
     *Hình 5: Giao diện tạo phương thức POST.*

6. **Bật API Key Required**  
   - Trong giao diện **Method Request** của **POST /students**:  
     - Nhấn **Edit** bên cạnh **Authorization**.  
     - Chọn **NONE** (API Key sẽ xử lý xác thực, không cần Cognito hoặc IAM Authorizer).  
     - Trong **API Key Required**, chọn **true** để yêu cầu API Key trong header `x-api-key`.  
       - **Giải thích**: Điều này đảm bảo mọi yêu cầu gửi đến **POST /students** phải chứa `StudentApiKey` (tạo ở mục 4.2) trong header `x-api-key`.  
     - Nhấn **Save** hoặc biểu tượng check (✔) để lưu cấu hình.  

     ![Giao diện bật API Key Required.](/images/5-creating-a-restful-api/4.5-creating-a-post-method/creating-a-post-method-06.png)
    *Hình 6: Giao diện bật API Key Required.*

7. **Kiểm Tra Trạng Thái Tạo Phương Thức**  
   - Sau khi cấu hình và nhấn **Save**, bạn sẽ thấy thông báo: _"Successfully created method ‘POST’. Redeploy your API for the update to take effect."_  
   - **Lưu ý quan trọng**: Phương thức **POST** sẽ không hoạt động cho đến khi bạn triển khai API vào một stage (mục 4.8).  
   - Để kiểm tra cấu hình:  
     - Trong **Resources**, chọn **POST** dưới `/students`.  
     - Xác minh:  
       - **Integration Request**: Hiển thị **Lambda Function: insertStudentData**.  
       - **Method Request**: **API Key Required: true**.  
     - Nếu gặp lỗi:  
       - _"Lambda function not found"_: Kiểm tra hàm `insertStudentData` tồn tại trong **Lambda** > **Functions** và vùng AWS khớp (`us-east-1`).  
       - _"AccessDenied"_: Kiểm tra vai trò IAM của tài khoản AWS có quyền `apigateway:PUT` để tạo method.  
       - _"Permission denied"_: Đảm bảo API Gateway có quyền gọi `insertStudentData` (AWS tự động thêm quyền khi bạn nhấn **OK**).  

     ![Thông báo thành công sau khi tạo phương thức POST.](/images/5-creating-a-restful-api/4.5-creating-a-post-method/creating-a-post-method-07.png)
     - *Hình 7: Thông báo thành công sau khi tạo phương thức POST.*

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Tích hợp Lambda Proxy** | **Lambda Proxy integration** cho phép gửi toàn bộ yêu cầu HTTP (headers, body) đến hàm `insertStudentData` và nhận phản hồi JSON với headers (như `Access-Control-Allow-Origin: '*'`). <br> Đảm bảo mã của `insertStudentData` (mục 3.2) xử lý đúng định dạng JSON đầu vào và trả về phản hồi hợp lệ. |
| **Bảo mật API Key** | Với **API Key Required: true**, yêu cầu gửi đến **POST /students** phải chứa header `x-api-key: <StudentApiKey>`. <br> Để tăng cường bảo mật, lưu API Key trong **AWS Secrets Manager** (xem mục 4.2). |
| **CORS** | Phương thức **POST** cần hỗ trợ CORS để giao diện web có thể gửi yêu cầu cross-origin. Điều này sẽ được cấu hình chi tiết ở mục 4.7 (kích hoạt CORS với phương thức **OPTIONS**). <br> Đảm bảo hàm `insertStudentData` trả về header `Access-Control-Allow-Origin: '*'` (hoặc domain CloudFront cụ thể, ví dụ: `https://d12345678.cloudfront.net`). |
| **Vùng AWS** | Đảm bảo vùng `us-east-1` khớp với hàm `insertStudentData`, bảng DynamoDB `studentData`, SES, và API `student`. Nếu sử dụng vùng khác (ví dụ: `us-west-2`), chọn đúng vùng trong **Lambda Region**. |
| **Xử lý lỗi** | - Nếu gặp lỗi _"Lambda function not found"_: <br> - Kiểm tra hàm `insertStudentData` tồn tại trong **Lambda** > **Functions**. <br> - Đảm bảo vùng AWS khớp (`us-east-1`). <br> - Nếu gặp lỗi `403 "Forbidden"` khi gọi API (sau khi deploy): <br> - Kiểm tra **API Key Required: true** và API Key `StudentApiKey` hợp lệ. <br> - Đảm bảo API Key được liên kết với Usage Plan (mục 4.3, 4.9). <br> - Nếu gặp lỗi `400`, `409`, hoặc `500` từ Lambda, kiểm tra log trong **CloudWatch** (log group `/aws/lambda/insertStudentData`) để gỡ lỗi: <br> - `400`: Body JSON không đúng định dạng (thiếu `studentid`, `name`, v.v.). <br> - `409`: `studentid` đã tồn tại (do **ConditionExpression**). <br> - `500`: Lỗi DynamoDB hoặc SES (ví dụ: email chưa xác minh trong SES). |
| **Tối ưu hóa** | - Thêm header `Access-Control-Allow-Origin` trong **Method Response** để đảm bảo CORS hoạt động đúng: <br> - Trong **Method Response** của **POST /students**, thêm **Status Code 200, 400, 409, 500** với header `Access-Control-Allow-Origin: '*'`. <br> - Trong **Integration Response**, ánh xạ phản hồi từ Lambda để xử lý các mã trạng thái. <br> - Cân nhắc sử dụng **AWS WAF** với API Gateway để bảo vệ khỏi các cuộc tấn công DDoS hoặc lạm dụng API Key. <br> - Nếu cần xác minh dữ liệu đầu vào, thêm **Request Validator** trong **Method Request** để kiểm tra body JSON có các trường bắt buộc (`studentid`, `name`, `class`, `birthdate`, `email`). |
| **Kiểm tra sớm** | - Sau khi tạo phương thức **POST**, xác minh cấu hình trong **Resources** > **POST /students** (**Integration Request**, **Method Request**). <br> - Sau khi deploy API (mục 4.8), kiểm tra phương thức **POST** bằng Postman hoặc curl. <br> - Kiểm tra bảng DynamoDB `studentData` (vào **DynamoDB** > **Tables** > `studentData` > **Explore items**) để xác minh bản ghi mới. <br> - Kiểm tra hộp thư (bao gồm Spam/Junk) của email nhận (ví dụ: `student4@example.com`) để xác minh email xác nhận từ SES. <br> - Nếu nhận lỗi `403 "Forbidden"`, kiểm tra API Key và cấu hình **API Key Required**. <br> - Nếu nhận lỗi `400`, `409`, hoặc `500`, kiểm tra log **CloudWatch** của hàm `insertStudentData`. |
| **Kiểm tra tích hợp với giao diện web** | Sau khi deploy API (mục 4.8) và liên kết Usage Plan (mục 4.9), sử dụng API Key trong giao diện web (sử dụng Tailwind CSS, chạy trên CloudFront) để gọi endpoint **POST /students**. |

> **Mẹo thực tiễn**: Xác minh cấu hình **Integration Request** và **API Key Required** trước khi triển khai API. Kiểm tra dữ liệu trong bảng `studentData` và email xác nhận từ SES bằng Postman để đảm bảo hàm `insertStudentData` hoạt động đúng.

---

## Kết Luận

Phương thức **POST /students** đã được tạo thành công trong API `student`, tích hợp với hàm Lambda `insertStudentData` và yêu cầu API Key `StudentApiKey`, sẵn sàng để triển khai và sử dụng trong giao diện web.

> **Bước tiếp theo**: Chuyển đến [Tạo Resource & Method cho tính năng Backup dữ liệu](/4-creating-a-restful-api/4.6-creating-a-backup-resource-and-method/) để tiếp tục!