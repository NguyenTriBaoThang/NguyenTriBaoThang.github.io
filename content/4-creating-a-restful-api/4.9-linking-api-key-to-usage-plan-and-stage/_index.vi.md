---
title: "Gắn API Key vào Usage Plan & Liên kết với REST API và Stage"
date: 2023-10-25
weight: 9
chapter: false
pre: "<b>4.9. </b>"
---

> **Mục tiêu**: Gắn API Key `StudentApiKey` (tạo ở mục 4.2) vào Usage Plan `StudentUsagePlan` (tạo ở mục 4.3) và liên kết với API `student` (tạo ở mục 4.1) trên stage `prod` (tạo ở mục 4.8). Điều này đảm bảo các yêu cầu đến các endpoint (**GET /students**, **POST /students**, **POST /backup**) phải sử dụng `StudentApiKey` trong header `x-api-key` và tuân theo giới hạn của `StudentUsagePlan` (Rate: 5 yêu cầu/giây, Burst: 10 yêu cầu, Quota: 1000 yêu cầu/ngày). Cấu hình này cho phép giao diện web (chạy trên CloudFront, sử dụng Tailwind CSS) truy cập API một cách an toàn và kiểm soát.

---

## Tổng Quan về API Key và Usage Plan trong API Gateway

- **API Key** (`StudentApiKey`) là một chuỗi xác thực dùng để kiểm soát truy cập vào các phương thức API (**GET /students**, **POST /students**, **POST /backup**), yêu cầu header `x-api-key` trong mỗi yêu cầu.  
- **Usage Plan** (`StudentUsagePlan`) quản lý giới hạn truy cập (Rate, Burst, Quota) và liên kết API Key với API/stage cụ thể.  
- Liên kết `StudentApiKey` với `StudentUsagePlan` và API `student` trên stage `prod` đảm bảo:  
  - Chỉ các yêu cầu có `StudentApiKey` hợp lệ mới được xử lý.  
  - Các yêu cầu tuân theo giới hạn: 5 yêu cầu/giây (Rate), 10 yêu cầu đồng thời (Burst), và 1000 yêu cầu/ngày (Quota).  
  - Giao diện web có thể gọi các endpoint một cách an toàn với CORS (mục 4.7) và **Invoke URL** (mục 4.8).  
- Sau khi hoàn tất, các endpoint sẽ sẵn sàng để sử dụng trong giao diện web với bảo mật API Key.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành mục 4.1 (tạo API `student`), mục 4.2 (tạo API Key `StudentApiKey`), mục 4.3 (tạo Usage Plan `StudentUsagePlan`), mục 4.4 (tạo phương thức **GET /students**), mục 4.5 (tạo phương thức **POST /students**), mục 4.6 (tạo resource `/backup` và phương thức **POST /backup**), mục 4.7 (kích hoạt CORS), mục 4.8 (triển khai API lên stage `prod`), và mục 3 (tạo các hàm Lambda `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, SES email xác minh). Đảm bảo tài khoản AWS đã sẵn sàng và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console**  
   - Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS của bạn.  
   - Trong thanh tìm kiếm ở đầu trang, nhập **API Gateway** và chọn dịch vụ **Amazon API Gateway** để vào giao diện quản lý.  
   - Kiểm tra vùng AWS: Đảm bảo bạn đang làm việc trong vùng AWS chính (giả định `us-east-1` để đồng bộ với các mục trước), kiểm tra vùng ở góc trên bên phải AWS Console. Vùng này phải khớp với API `student`, các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`), bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, và SES.  

     ![Giao diện AWS Console với thanh tìm kiếm API Gateway.](/images/5-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/linking-api-key-to-usage-plan-and-stage-01.png)
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm API Gateway.*

2. **Điều Hướng Đến Mục API Keys**  
   - Trong giao diện chính của Amazon API Gateway, nhìn vào menu điều hướng bên trái.  
   - Chọn **API Keys** để xem danh sách các API Key hiện có.  
   - Danh sách sẽ hiển thị `StudentApiKey` (tạo ở mục 4.2). Nếu không thấy, kiểm tra lại vùng AWS hoặc làm mới trang.  

     ![Menu điều hướng với tùy chọn API Keys.](/images/5-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/linking-api-key-to-usage-plan-and-stage-02.png)
     *Hình 2: Menu điều hướng với tùy chọn API Keys.*

3. **Chọn API Key StudentApiKey**  
   - Trong danh sách **API Keys**, tìm và chọn `StudentApiKey`.  
   - Bạn sẽ được chuyển đến trang chi tiết của `StudentApiKey`, hiển thị thông tin như **Value** (giá trị API Key, có thể ẩn), **Usage Plans**, và các tùy chọn cấu hình.  

     ![Trang chi tiết của StudentApiKey.](/images/5-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/linking-api-key-to-usage-plan-and-stage-03.png)
     *Hình 3: Trang chi tiết của StudentApiKey.*

4. **Gắn StudentApiKey vào Usage Plan**  
   - Trong trang chi tiết của `StudentApiKey`, nhấn **Add to Usage Plan** (hoặc **Actions** > **Add to Usage Plan** tùy phiên bản Console).  
   - Trong mục **Add key to usage plan**:  
     - **Usage Plan**: Chọn `StudentUsagePlan` từ dropdown (tạo ở mục 4.3).  
     - **Lưu ý**: Nếu `StudentUsagePlan` không xuất hiện, kiểm tra xem Usage Plan đã được tạo trong cùng vùng AWS (`us-east-1`).  
   - Nhấn **Save** để gắn `StudentApiKey` vào `StudentUsagePlan`.  
   - Kiểm tra: Sau khi lưu, trong trang chi tiết của `StudentApiKey`, phần **Usage Plans** sẽ hiển thị `StudentUsagePlan`.  

     ![Giao diện gắn StudentApiKey vào StudentUsagePlan.](/images/5-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/linking-api-key-to-usage-plan-and-stage-04.png)
     *Hình 4: Giao diện gắn StudentApiKey vào StudentUsagePlan.*

5. **Kiểm Tra Trạng Thái Gắn API Key**  
   - Sau khi nhấn **Save**, bạn sẽ thấy thông báo: _"Successfully added 'StudentApiKey' to 'StudentUsagePlan'."_  
   - Nếu không thấy thông báo hoặc gặp lỗi:  
     - _"Usage Plan not found"_: Kiểm tra `StudentUsagePlan` tồn tại trong **Usage Plans** (mục 4.3).  
     - _"AccessDenied"_: Kiểm tra vai trò IAM của tài khoản AWS có quyền `apigateway:PUT` để gắn API Key.  
     - _"API Key already added"_: Nếu `StudentApiKey` đã được gắn trước đó, thông báo này có thể xuất hiện; bỏ qua và tiếp tục bước tiếp theo.  

     ![Thông báo trạng thái gắn API Key.](/images/5-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/linking-api-key-to-usage-plan-and-stage-05.png)
     *Hình 5: Thông báo trạng thái gắn API Key.*

6. **Điều Hướng Đến Mục Usage Plans**  
   - Trong menu bên trái của Amazon API Gateway, chọn **Usage Plans** để xem danh sách các Usage Plan.  
   - Danh sách sẽ hiển thị `StudentUsagePlan` (tạo ở mục 4.3). Nếu không thấy, kiểm tra lại vùng AWS hoặc làm mới trang.  

     ![Menu điều hướng với tùy chọn Usage Plans.](/images/5-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/linking-api-key-to-usage-plan-and-stage-06.png)
     - *Hình 6: Menu điều hướng với tùy chọn Usage Plans.*

7. **Chọn Usage Plan StudentUsagePlan**  
   - Trong danh sách **Usage Plans**, tìm và chọn `StudentUsagePlan`.  
   - Bạn sẽ được chuyển đến trang chi tiết của `StudentUsagePlan`, hiển thị thông tin như **Throttling** (Rate: 5, Burst: 10), **Quota** (1000 yêu cầu/ngày), **API Keys**, và **Associated APIs and Stages**.  

     ![Trang chi tiết của StudentUsagePlan.](/images/5-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/linking-api-key-to-usage-plan-and-stage-07.png)
     - *Hình 7: Trang chi tiết của StudentUsagePlan.*

8. **Liên Kết API và Stage**  
   - Trong trang chi tiết của `StudentUsagePlan`, nhấn **Add API Stage** (hoặc **Actions** > **Add API Stage** tùy phiên bản Console). 

   ![Nhấn vào nút Add API Stage.](/images/5-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/linking-api-key-to-usage-plan-and-stage-08.png)
     - *Hình 8: Nhấn vào nút Add API Stage.*

   - Trong giao diện **Add API Stage**:  
     - **API**: Chọn `student` từ dropdown (tạo ở mục 4.1).  
     - **Stage**: Chọn `prod` từ dropdown (tạo ở mục 4.8).  
     - **Lưu ý**: Nếu `student` hoặc `prod` không xuất hiện, kiểm tra xem API `student` và stage `prod` đã được tạo trong cùng vùng AWS (`us-east-1`).  
   - Nhấn **Add to Usage Plan** để liên kết.  
   - Kiểm tra: Trong trang chi tiết của `StudentUsagePlan`, phần **Associated APIs and Stages** sẽ hiển thị `student:prod`.  

     ![Giao diện liên kết API và Stage.](/images/5-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/linking-api-key-to-usage-plan-and-stage-09.png)
     *Hình 9: Giao diện liên kết API và Stage.*

9. **Kiểm Tra Trạng Thái Liên Kết API và Stage**  
   - Sau khi nhấn **Add to Usage Plan**, bạn sẽ thấy thông báo: _"Successfully added stage 'prod' to usage plan."_  
   - Để xác minh:  
     - Trong **Usage Plans** > `StudentUsagePlan`:  
       - Kiểm tra **API Keys** hiển thị `StudentApiKey`.  
       - Kiểm tra **Associated APIs and Stages** hiển thị `student:prod`.  
     - Nếu không thấy thông báo hoặc gặp lỗi:  
       - _"API or Stage not found"_: Kiểm tra API `student` và stage `prod` tồn tại (mục 4.1, 4.8).  
       - _"AccessDenied"_: Kiểm tra vai trò IAM có quyền `apigateway:PUT` để liên kết API/stage.  
       - _"Stage already associated"_: Nếu `student:prod` đã được liên kết trước đó, thông báo này có thể xuất hiện; bỏ qua.  

     ![Thông báo trạng thái liên kết API và Stage.](/images/5-creating-a-restful-api/4.9-linking-api-key-to-usage-plan-and-stage/linking-api-key-to-usage-plan-and-stage-10.png)
     - *Hình 10: Thông báo trạng thái liên kết API và Stage.*

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Kiểm tra toàn bộ cấu hình** | - **API Key**: `StudentApiKey` đã được gắn vào `StudentUsagePlan`. <br> - **Usage Plan**: `StudentUsagePlan` áp dụng giới hạn Rate (5 yêu cầu/giây), Burst (10 yêu cầu), Quota (1000 yêu cầu/ngày). <br> - **API/Stage**: `student:prod` đã được liên kết, áp dụng giới hạn của `StudentUsagePlan` cho các endpoint (**GET /students**, **POST /students**, **POST /backup**). <br> - **API Key Required**: Các phương thức đã bật **API Key Required: true** (mục 4.4, 4.5, 4.6). |
| **Bảo mật API Key** | Yêu cầu đến các endpoint phải chứa header `x-api-key: <StudentApiKey>`. <br> Lưu API Key trong **AWS Secrets Manager** để tăng cường bảo mật. |
| **CORS** | Đảm bảo CORS đã được kích hoạt (mục 4.7) với phương thức **OPTIONS** và header `Access-Control-Allow-Origin: '*'` (hoặc domain CloudFront cụ thể). <br> Các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`) phải trả về header `Access-Control-Allow-Origin: '*'` (đã cấu hình ở mục 3.1, 3.2, 3.3). |
| **Vùng AWS** | Đảm bảo vùng `us-east-1` khớp với API `student`, stage `prod`, `StudentApiKey`, `StudentUsagePlan`, các hàm Lambda, bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, và SES. |
| **Xử lý lỗi** | - Nếu gặp lỗi `403 "Forbidden"` khi gọi endpoint: <br> - Kiểm tra `StudentApiKey` hợp lệ và được gắn vào `StudentUsagePlan`. <br> - Đảm bảo `student:prod` được liên kết với `StudentUsagePlan`. <br> - Xác minh **API Key Required: true** trong **Method Request** (mục 4.4, 4.5, 4.6). <br> - Nếu gặp lỗi `429 "Too Many Requests"`: <br> - Kiểm tra giới hạn Rate (5 yêu cầu/giây), Burst (10 yêu cầu), hoặc Quota (1000 yêu cầu/ngày) trong `StudentUsagePlan`. <br> - Xem thống kê sử dụng trong **Usage Plans** > `StudentUsagePlan` > **Usage**. <br> - Nếu gặp lỗi `500` từ Lambda, kiểm tra log trong **CloudWatch** (log groups `/aws/lambda/getStudentData`, `/aws/lambda/insertStudentData`, `/aws/lambda/BackupDynamoDBAndSendEmail`). <br> - Nếu không thấy thông báo thành công, kiểm tra vùng AWS hoặc làm mới trang Console. |
| **Tối ưu hóa** | - Bật **CloudWatch Metrics** cho `StudentUsagePlan` để theo dõi số lượng yêu cầu: <br> - Trong **Usage Plans** > `StudentUsagePlan`, chọn **Enable usage plan metrics**. <br> - Kiểm tra trong **CloudWatch** > **Metrics** > **API Gateway** > **UsagePlanId**. <br> - Cân nhắc sử dụng **AWS WAF** với API Gateway để bảo vệ khỏi các cuộc tấn công DDoS hoặc lạm dụng API Key. <br> - Nếu cần nhiều API Key (ví dụ: cho nhiều ứng dụng web), tạo thêm API Key và gắn vào `StudentUsagePlan`. |
| **Kiểm tra sớm** | - Sau khi gắn `StudentApiKey` và liên kết `student:prod`, kiểm tra cấu hình trong **Usage Plans** > `StudentUsagePlan`. <br> - Kiểm tra các endpoint bằng Postman hoặc curl với `StudentApiKey`. <br> - Kết quả mong đợi: <br> - **GET /students**: Trả về danh sách sinh viên từ DynamoDB `studentData`. <br> - **POST /students**: Lưu bản ghi mới vào DynamoDB và gửi email xác nhận qua SES. <br> - **POST /backup**: Tạo tệp backup trong S3 `student-backup-20250706` và gửi email thông báo. <br> - Kiểm tra từ giao diện web (mở **Developer Tools** > **Network** trong trình duyệt) để xác minh không có lỗi CORS, 403, hoặc 429. |
| **Kiểm tra tích hợp với giao diện web** | Sử dụng **Invoke URL** và `StudentApiKey` trong giao diện web (sử dụng Tailwind CSS, chạy trên CloudFront) để gọi các endpoint (**GET /students**, **POST /students**, **POST /backup**). |

> **Mẹo thực tiễn**: Sau khi gắn `StudentApiKey` và liên kết `student:prod`, kiểm tra các endpoint bằng Postman với header `x-api-key` trước khi tích hợp với giao diện web. Xác minh dữ liệu trong DynamoDB `studentData`, bucket S3 `student-backup-20250706`, và email SES để đảm bảo các endpoint hoạt động đúng.

---

## Kết Luận

`StudentApiKey` đã được gắn thành công vào `StudentUsagePlan` và liên kết với API `student` trên stage `prod`, đảm bảo các endpoint (**GET /students**, **POST /students**, **POST /backup**) được bảo mật và tuân theo giới hạn truy cập, sẵn sàng để sử dụng trong giao diện web.

> **Bước tiếp theo**: Chuyển đến [Tiếp tục cấu hình hoặc tích hợp giao diện web](5-designing-the-website-interface/) để hoàn thiện hệ thống!