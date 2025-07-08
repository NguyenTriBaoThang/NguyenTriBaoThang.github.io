---
title: "Tạo phương thức GET để truy xuất dữ liệu"
date: 2023-10-25
weight: 4
chapter: false
pre: "<b>4.4. </b>"
---

> **Mục tiêu**: Tạo phương thức **GET** trên resource `/students` trong API `student` (tạo ở mục 4.1) để tích hợp với hàm Lambda `getStudentData` (tạo ở mục 3.1), cho phép truy xuất danh sách sinh viên từ bảng DynamoDB `studentData`. Phương thức sẽ yêu cầu API Key (`StudentApiKey`, tạo ở mục 4.2) trong header `x-api-key` để bảo mật, và chuẩn bị cho việc kích hoạt CORS (mục 4.7) để giao diện web (chạy trên CloudFront) có thể gửi yêu cầu.

---

## Tổng Quan về Phương Thức GET

- Phương thức **GET /students** sẽ gọi hàm Lambda `getStudentData` để lấy tất cả bản ghi từ bảng DynamoDB `studentData` (các trường: `studentid`, `name`, `class`, `birthdate`, `email`).  
- Hàm `getStudentData` trả về phản hồi JSON với header `Access-Control-Allow-Origin: '*'` để hỗ trợ CORS, phù hợp với giao diện web.  
- **API Key Required** đảm bảo chỉ các yêu cầu có `StudentApiKey` hợp lệ mới được xử lý.  
- Sau khi tạo, API cần được triển khai (mục 4.8) để phương thức **GET** có hiệu lực.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành mục 4.1 (tạo API `student`), mục 4.2 (tạo API Key `StudentApiKey`), mục 4.3 (tạo Usage Plan `StudentUsagePlan`), và mục 3 (tạo các hàm Lambda `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, SES email xác minh). Đảm bảo tài khoản AWS đã sẵn sàng và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console**  
   - Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS của bạn.  
   - Trong thanh tìm kiếm ở đầu trang, nhập **API Gateway** và chọn dịch vụ **Amazon API Gateway** để vào giao diện quản lý.  
   - Kiểm tra vùng AWS: Đảm bảo bạn đang làm việc trong vùng AWS chính (giả định `us-east-1` để đồng bộ với các mục trước), kiểm tra vùng ở góc trên bên phải AWS Console. Vùng này phải khớp với API `student`, hàm Lambda `getStudentData`, bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, và SES.  

     ![creating-a-get-method-01](/images/5-creating-a-restful-api/4.4-creating-a-get-method/creating-a-get-method-01.png)
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm API Gateway.*

2. **Điều Hướng Đến Mục APIs**  
   - Trong giao diện chính của Amazon API Gateway, nhìn vào menu điều hướng bên trái.  
   - Chọn **APIs** để xem danh sách các API hiện có.  
   - Danh sách sẽ hiển thị API `student` (tạo ở mục 4.1). Nếu không thấy, kiểm tra lại vùng AWS hoặc làm mới trang.  

     ![Menu điều hướng với tùy chọn APIs.](/images/5-creating-a-restful-api/4.4-creating-a-get-method/creating-a-get-method-02.png)
     *Hình 2: Menu điều hướng với tùy chọn APIs.*

3. **Chọn API student**  
   - Trong danh sách **APIs**, tìm và chọn API có tên `student`.  
   - Bạn sẽ được chuyển đến trang quản lý API `student`, hiển thị các mục như **Resources**, **Stages**, **API Keys**, v.v.  
   - Chọn **Resources** từ menu bên trái để bắt đầu cấu hình resource và method.  

     ![Trang quản lý API student với tùy chọn Resources.](/images/5-creating-a-restful-api/4.4-creating-a-get-method/creating-a-get-method-03.png)
     *Hình 3: Trang quản lý API student với tùy chọn Resources.*

4. **Tạo Resource /students**  
   - Trong giao diện **Resources**, bạn sẽ thấy cây tài nguyên với gốc là `/`.  
   - Nhấn **Actions** > **Create Resource** để tạo resource mới.  
   - Cấu hình resource:  
     - **Resource Name**: Nhập `students`.  
     - **Resource Path**: Nhập `/students` (hoặc để mặc định, sẽ tự động là `/students`).  
     - **Enable API Gateway CORS**: Chọn để chuẩn bị cho việc kích hoạt CORS (mục 4.7).  
   - Nhấn **Create Resource** để tạo.  
   - Kiểm tra: Resource `/students` sẽ xuất hiện dưới gốc `/` trong cây tài nguyên.  

     ![Giao diện tạo resource /students.](/images/5-creating-a-restful-api/4.4-creating-a-get-method/creating-a-get-method-04.png)  
     *Hình 4: Giao diện tạo resource /students.*

5. **Tạo Phương Thức GET**  
   - Trong cây tài nguyên, chọn resource `/students`.  
   - Nhấn **Actions** > **Create Method**.  
   - Trong dropdown dưới `/students`, chọn **GET** và nhấn biểu tượng check (✔) để xác nhận.  
   - **Lưu ý**: Nếu dropdown không hiển thị **GET**, đảm bảo bạn đã chọn đúng resource `/students`.  
   - **Integration Type**: Chọn **Lambda Function** để tích hợp với hàm Lambda.  

     ![Giao diện tạo phương thức GET.](/images/5-creating-a-restful-api/4.4-creating-a-get-method/creating-a-get-method-05.png)
     *Hình 5: Giao diện tạo phương thức GET.*

6. **Cấu Hình Tích Hợp Lambda**  
   - Trong giao diện cấu hình phương thức **GET**:  
     - **Use Lambda Proxy integration**: Chọn (để gửi toàn bộ yêu cầu HTTP đến hàm Lambda và nhận phản hồi JSON với headers).  
     - **Lambda Region**: Chọn `us-east-1` (hoặc vùng AWS của bạn, phải khớp với vùng của hàm `getStudentData`).  
     - **Lambda Function**: Nhập `getStudentData`.  
       - **Lưu ý**: Nếu hàm `getStudentData` không xuất hiện trong danh sách gợi ý, nhập thủ công và đảm bảo hàm tồn tại trong Lambda (mục 3.1).  
     - Nhấn **Save** để lưu cấu hình.  
   - Nếu AWS yêu cầu cấp quyền, nhấn **OK** để cho phép API Gateway gọi hàm Lambda `getStudentData`. AWS sẽ tự động thêm chính sách IAM vào vai trò của hàm Lambda (thường là `LambdaGetStudentRole` từ mục 3.1) với quyền `lambda:InvokeFunction`.  

     ![Giao diện cấu hình tích hợp Lambda.](/images/5-creating-a-restful-api/4.4-creating-a-get-method/creating-a-get-method-06.png)
     *Hình 6: Giao diện cấu hình tích hợp Lambda.*

7. **Bật API Key Required**  
   - Trong giao diện **Method Request** của **GET /students**:  
     - Nhấn **Edit** bên cạnh **Authorization**.  
     - Chọn **NONE** (API Key sẽ xử lý xác thực, không cần Cognito hoặc IAM Authorizer).  
     - Trong **API Key Required**, chọn **true** để yêu cầu API Key trong header `x-api-key`.  
       - **Giải thích**: Điều này đảm bảo mọi yêu cầu gửi đến **GET /students** phải chứa `StudentApiKey` (tạo ở mục 4.2) trong header `x-api-key`.  
     - Nhấn **Save** hoặc biểu tượng check (✔) để lưu cấu hình.  

     ![Giao diện bật API Key Required.](/images/5-creating-a-restful-api/4.4-creating-a-get-method/creating-a-get-method-07.png)
     *Hình 7: Giao diện bật API Key Required.*

8. **Kiểm Tra Trạng Thái Tạo Phương Thức**  
   - Sau khi cấu hình và nhấn **Save**, bạn sẽ thấy thông báo: _"Successfully created method ‘GET’. Redeploy your API for the update to take effect."_  
   - **Lưu ý quan trọng**: Phương thức **GET** sẽ không hoạt động cho đến khi bạn triển khai API vào một stage (mục 4.8).  
   - Để kiểm tra cấu hình:  
     - Trong **Resources**, chọn **GET** dưới `/students`.  
     - Xác minh:  
       - **Integration Request**: Hiển thị **Lambda Function: getStudentData**.  
       - **Method Request**: **API Key Required: true**.  
     - Nếu gặp lỗi:  
       - _"Lambda function not found"_: Kiểm tra hàm `getStudentData` tồn tại trong Lambda và vùng AWS khớp (`us-east-1`).  
       - _"AccessDenied"_: Kiểm tra vai trò IAM của tài khoản AWS có quyền `apigateway:PUT` để tạo method.  
       - _"Permission denied"_: Đảm bảo API Gateway có quyền gọi `getStudentData` (AWS tự động thêm quyền khi bạn nhấn **OK**).  

     ![Thông báo thành công sau khi tạo phương thức GET.](/images/5-creating-a-restful-api/4.4-creating-a-get-method/creating-a-get-method-08.png)
     *Hình 8: Thông báo thành công sau khi tạo phương thức GET.*

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Tích hợp Lambda Proxy** | **Lambda Proxy integration** cho phép gửi toàn bộ yêu cầu HTTP (headers, query parameters, body) đến hàm `getStudentData` và nhận phản hồi JSON với headers (như `Access-Control-Allow-Origin: '*'`). <br> Đảm bảo mã của `getStudentData` (mục 3.1) trả về phản hồi đúng định dạng. |
| **Bảo mật API Key** | Với **API Key Required: true**, yêu cầu gửi đến **GET /students** phải chứa header `x-api-key: <StudentApiKey>`. <br> Để tăng cường bảo mật, lưu API Key trong **AWS Secrets Manager** (xem mục 4.2). |
| **CORS** | Phương thức **GET** cần hỗ trợ CORS để giao diện web có thể gửi yêu cầu cross-origin. Điều này sẽ được cấu hình chi tiết ở mục 4.7 (kích hoạt CORS với phương thức **OPTIONS**). <br> Đảm bảo hàm `getStudentData` trả về header `Access-Control-Allow-Origin: '*'` (hoặc domain CloudFront cụ thể, ví dụ: `https://d12345678.cloudfront.net`). |
| **Vùng AWS** | Đảm bảo vùng `us-east-1` khớp với hàm `getStudentData`, bảng DynamoDB `studentData`, và API `student`. Nếu sử dụng vùng khác (ví dụ: `us-west-2`), chọn đúng vùng trong **Lambda Region**. |
| **Xử lý lỗi** | - Nếu gặp lỗi _"Lambda function not found"_: <br> - Kiểm tra hàm `getStudentData` tồn tại trong **Lambda** > **Functions**. <br> - Đảm bảo vùng AWS khớp (`us-east-1`). <br> - Nếu gặp lỗi `403 "Forbidden"` khi gọi API (sau khi deploy): <br> - Kiểm tra **API Key Required: true** và API Key `StudentApiKey` hợp lệ. <br> - Đảm bảo API Key được liên kết với Usage Plan (mục 4.3, 4.9). <br> - Nếu gặp lỗi `500` từ Lambda, kiểm tra log trong **CloudWatch** (log group `/aws/lambda/getStudentData`) để gỡ lỗi. |
| **Tối ưu hóa** | - Thêm header `Access-Control-Allow-Origin` trong **Method Response** để đảm bảo CORS hoạt động đúng: <br> - Trong **Method Response** của **GET /students**, thêm **Status Code 200** với header `Access-Control-Allow-Origin: '*'`. <br> - Trong **Integration Response**, ánh xạ phản hồi từ Lambda để trả về JSON đúng định dạng. <br> - Cân nhắc sử dụng **AWS WAF** với API Gateway để bảo vệ khỏi các cuộc tấn công DDoS hoặc lạm dụng API Key. <br> - Nếu bảng `studentData` lớn, đảm bảo hàm `getStudentData` xử lý phân trang (như trong mã cải tiến ở mục 3.1) để tránh vượt giới hạn Scan. |
| **Kiểm tra sớm** | - Sau khi tạo phương thức **GET**, xác minh cấu hình trong **Resources** > **GET /students** (**Integration Request**, **Method Request**). <br> - Sau khi deploy API (mục 4.8), kiểm tra phương thức **GET** bằng Postman hoặc curl. <br> - Nếu nhận lỗi `403 "Forbidden"`, kiểm tra API Key hoặc cấu hình **API Key Required**. <br> - Nếu nhận lỗi `500`, kiểm tra log **CloudWatch** của hàm `getStudentData`. |
| **Kiểm tra tích hợp với giao diện web** | Sau khi deploy API (mục 4.8) và liên kết Usage Plan (mục 4.9), sử dụng API Key trong giao diện web (sử dụng Tailwind CSS, chạy trên CloudFront) để gọi endpoint **GET /students**. |

> **Mẹo thực tiễn**: Xác minh cấu hình **Integration Request** và **API Key Required** trước khi triển khai API. Kiểm tra phản hồi JSON từ hàm `getStudentData` bằng Postman để đảm bảo dữ liệu sinh viên được trả về đúng định dạng.

---

## Kết Luận

Phương thức **GET /students** đã được tạo thành công trong API `student`, tích hợp với hàm Lambda `getStudentData` và yêu cầu API Key `StudentApiKey`, sẵn sàng để triển khai và sử dụng trong giao diện web.

> **Bước tiếp theo**: Chuyển đến [Tạo phương thức POST để lưu dữ liệu](/4-creating-a-restful-api/4.5-creating-a-post-method/) để tiếp tục!