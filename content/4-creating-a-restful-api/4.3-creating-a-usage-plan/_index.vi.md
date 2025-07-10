---
title: "Thiết lập Usage Plan (Kế hoạch sử dụng)"
date: 2025-07-09
weight: 3
chapter: false
pre: "<b>4.3. </b>"
---

> **Mục tiêu**: Tạo một Usage Plan có tên `StudentUsagePlan` trong AWS API Gateway để kiểm soát và giới hạn truy cập vào API `student` (tạo ở mục 4.1) thông qua API Key `StudentApiKey` (tạo ở mục 4.2). Usage Plan sẽ áp dụng giới hạn tốc độ (**Rate**: 5 yêu cầu/giây, **Burst**: 10 yêu cầu) và quota (1000 yêu cầu/ngày), đảm bảo kiểm soát chi phí, ngăn chặn lạm dụng, và bảo mật các endpoint (`GET /students`, `POST /students`, `POST /backup`) khi được gọi từ giao diện web (chạy trên CloudFront).

---

## Tổng Quan về Usage Plan trong API Gateway

- Usage Plan là cơ chế của API Gateway để quản lý cách client sử dụng API thông qua API Key, bao gồm:  
  - **Rate Limiting**: Giới hạn số yêu cầu mỗi giây (**Rate**) và số yêu cầu đồng thời tối đa (**Burst**).  
  - **Quota**: Giới hạn tổng số yêu cầu trong một khoảng thời gian (ví dụ: ngày, tuần, tháng).  
- Trong hệ thống này, `StudentUsagePlan` sẽ:  
  - Liên kết với API Key `StudentApiKey` để xác thực yêu cầu.  
  - Áp dụng cho API `student` và stage (ví dụ: `prod`, sẽ tạo ở mục 4.8).  
  - Đảm bảo giao diện web chỉ gửi yêu cầu hợp lệ với API Key trong giới hạn định sẵn.  
- Usage Plan giúp bảo vệ API khỏi các cuộc tấn công lạm dụng (như DDoS) và kiểm soát chi phí sử dụng API Gateway.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành mục 4.1 (tạo API `student`), mục 4.2 (tạo API Key `StudentApiKey`), và mục 3 (tạo các hàm Lambda `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, SES email xác minh). Đảm bảo tài khoản AWS đã sẵn sàng và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console**  
   - Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS của bạn.  
   - Trong thanh tìm kiếm ở đầu trang, nhập **API Gateway** và chọn dịch vụ **Amazon API Gateway** để vào giao diện quản lý.  
   - Kiểm tra vùng AWS: Đảm bảo bạn đang làm việc trong vùng AWS chính (ví dụ: `us-east-1`), kiểm tra vùng ở góc trên bên phải AWS Console. Vùng này phải khớp với API `student` (tạo ở mục 4.1) và các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`).  

     ![Giao diện AWS Console với thanh tìm kiếm API Gateway.](/images/5-creating-a-restful-api/4.3-creating-a-usage-plan/creating-a-usage-plan-01.png)
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm API Gateway.*

2. **Điều Hướng Đến Mục Usage Plans**  
   - Trong giao diện chính của Amazon API Gateway, nhìn vào menu điều hướng bên trái.  
   - Chọn **Usage Plans** để xem danh sách các Usage Plan hiện có. Nếu bạn chưa tạo plan nào, danh sách sẽ trống.  
   - Giao diện sẽ hiển thị các tùy chọn để tạo hoặc quản lý Usage Plan.  

     ![Menu điều hướng với tùy chọn Usage Plans.](/images/5-creating-a-restful-api/4.3-creating-a-usage-plan/creating-a-usage-plan-02.png)
     *Hình 2: Menu điều hướng với tùy chọn Usage Plans.*

3. **Khởi Tạo Quá Trình Tạo Usage Plan**  
   - Trong giao diện **Usage Plans**, nhấn nút **Create** (hoặc **Create usage plans** tùy phiên bản Console) ở góc trên bên phải để bắt đầu cấu hình Usage Plan mới.  

     ![Nút Create trong giao diện Usage Plans.](/images/5-creating-a-restful-api/4.3-creating-a-usage-plan/creating-a-usage-plan-03.png)
     *Hình 3: Nút Create trong giao diện Usage Plans.*

4. **Cấu Hình Usage Plan**  
   - Trong mục **Create Usage Plan**:  
     - **Name**: Nhập chính xác `StudentUsagePlan`. Tên này giúp bạn dễ dàng nhận diện plan khi liên kết với API Key và stage.  
     - **Description**: Nhập *Usage Plan để kiểm soát truy cập vào StudentManagementAPI* (hoặc mô tả tương tự để rõ ràng mục đích).  
     - **Enable throttling**: Chọn để bật giới hạn tốc độ.  
       - **Rate**: Nhập **5** (5 yêu cầu/giây).  
       - **Burst**: Nhập **10** (10 yêu cầu đồng thời tối đa).  
       - **Giải thích**:  
         - **Rate** giới hạn số yêu cầu mỗi giây mà client (với API Key) có thể gửi.  
         - **Burst** giới hạn số yêu cầu đồng thời tối đa để xử lý các đợt yêu cầu đột biến.  
         - Giá trị này phù hợp với ứng dụng quy mô nhỏ như hệ thống quản lý sinh viên.  

     ![Giao diện cấu hình Usage Plan.](/images/5-creating-a-restful-api/4.3-creating-a-usage-plan/creating-a-usage-plan-04.png)
     *Hình 4: Giao diện cấu hình Usage Plan.*  

     - **Enable quota**: Chọn để bật giới hạn quota.  
       - **Quota**: Nhập **1000** và chọn **requests per Day** (1000 yêu cầu/ngày).  
       - **Giải thích**: Quota giới hạn tổng số yêu cầu hàng ngày, giúp kiểm soát chi phí và ngăn lạm dụng.  
     - Giữ các thiết lập khác ở giá trị mặc định (ví dụ: không bật **Enable usage plan metrics** trừ khi bạn cần theo dõi chi tiết).  
   - Nhấn **Next** để tiếp tục.  

     ![Nhấn nút tạo.](/images/5-creating-a-restful-api/4.3-creating-a-usage-plan/creating-a-usage-plan-05.png)
     *Hình 5: Nhấn nút tạo.*

5. **Kiểm Tra Trạng Thái Tạo Usage Plan**  
   - Sau khi nhấn **Create**, bạn sẽ thấy thông báo: _"Successfully created usage plan ‘StudentUsagePlan’."_  
   - Trong danh sách **Usage Plans**, chọn `StudentUsagePlan` để xem chi tiết.  
   - Xác minh:  
     - **Throttling**: Rate = 5 yêu cầu/giây, Burst = 10 yêu cầu.  
     - **Quota**: 1000 yêu cầu/ngày.  
     - **API Keys**: `StudentApiKey` đã được liên kết.  
   - Nếu không thấy thông báo hoặc gặp lỗi:  
     - Kiểm tra quyền IAM của tài khoản AWS có bao gồm `apigateway:POST` để tạo Usage Plan.  
     - Đảm bảo bạn đang ở đúng vùng AWS (`us-east-1`).  
     - Làm mới trang hoặc kiểm tra lại danh sách **Usage Plans**.  

      ![Trang chi tiết Usage Plan sau khi tạo.](/images/5-creating-a-restful-api/4.3-creating-a-usage-plan/creating-a-usage-plan-06.png)
      *Hình 6: Trang chi tiết Usage Plan sau khi tạo.*

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Liên kết với Stage** | Usage Plan sẽ được liên kết với stage `prod` của API `student` ở mục 4.9. Sau khi deploy API (mục 4.8), bạn cần quay lại `StudentUsagePlan` để thêm API `student` và stage `prod`. <br> - Trong **Associated APIs and Stages**, chọn **Add API Stage**, chọn API `student` và stage `prod`. |
| **Bảo mật API Key** | Đảm bảo `StudentApiKey` đã được sao chép và lưu an toàn (mục 4.2). Không nhúng API Key trực tiếp trong mã JavaScript của giao diện web. Sử dụng biến môi trường hoặc AWS Secrets Manager: <br> - Vào **AWS Secrets Manager** > **Store a new secret** > Chọn **Other type of secret** > Nhập API Key. <br> - Đặt tên bí mật (ví dụ: `student-api-key`) và truy xuất trong giao diện web qua AWS SDK. |
| **Giới hạn Rate và Quota** | **Rate**: 5 yêu cầu/giây và **Burst**: 10 yêu cầu phù hợp cho ứng dụng quy mô nhỏ. Nếu cần phục vụ nhiều người dùng hơn, tăng giá trị (ví dụ: Rate = 100, Burst = 200). <br> **Quota**: 1000 yêu cầu/ngày đủ cho thử nghiệm. Nếu cần, tăng quota (ví dụ: 10,000 yêu cầu/ngày) trong môi trường production. |
| **Xử lý lỗi** | Nếu gặp lỗi _"AccessDenied"_: <br> - Kiểm tra quyền IAM của tài khoản AWS (`apigateway:POST`, `apigateway:PUT` để tạo và liên kết Usage Plan). <br> - Đảm bảo API Key `StudentApiKey` tồn tại (mục 4.2). <br> Nếu client nhận lỗi `429 "Too Many Requests"` khi gọi API, kiểm tra: <br> - Yêu cầu vượt quá **Rate** hoặc **Burst**. <br> - Quota 1000 yêu cầu/ngày đã bị sử dụng hết (xem trong **Usage Plans** > **Usage**). <br> Nếu Usage Plan không hiển thị, làm mới trang hoặc kiểm tra lại vùng AWS. |
| **Tối ưu hóa** | - Bật **CloudWatch Metrics** cho Usage Plan để theo dõi số lượng yêu cầu: <br> - Trong `StudentUsagePlan`, chọn **Enable usage plan metrics**. <br> - Kiểm tra trong **CloudWatch** > **Metrics** > **API Gateway** > **UsagePlanId**. <br> - Cân nhắc sử dụng AWS WAF với API Gateway để bảo vệ khỏi các cuộc tấn công DDoS hoặc lạm dụng API Key. <br> - Nếu cần nhiều client (ví dụ: nhiều ứng dụng web), tạo thêm API Key và liên kết với cùng `StudentUsagePlan`. |
| **Kiểm tra sớm** | - Sau khi tạo `StudentUsagePlan`, xác minh plan xuất hiện trong danh sách **Usage Plans** và `StudentApiKey` được liên kết. <br> - Sau khi deploy API (mục 4.8), kiểm tra Usage Plan bằng cách gọi endpoint với API Key sử dụng Postman hoặc curl. <br> - Nếu nhận lỗi `403 "Forbidden"`, kiểm tra API Key có được liên kết với Usage Plan và method có yêu cầu **API Key Required: true** (mục 4.4, 4.5, 4.6). |
| **Kiểm tra tích hợp với giao diện web** | Sau khi liên kết Usage Plan với stage `prod` (mục 4.9), sử dụng API Key trong giao diện web để gọi các endpoint (`GET /students`, `POST /students`, `POST /backup`). |

> **Mẹo thực tiễn**: Xác minh `StudentUsagePlan` được cấu hình đúng với **Rate**, **Burst**, và **Quota** trước khi liên kết với stage `prod`. Kiểm tra số lượng yêu cầu qua CloudWatch sau khi thử nghiệm API.

---

## Kết Luận

Usage Plan `StudentUsagePlan` đã được tạo thành công trong AWS API Gateway, áp dụng giới hạn **Rate** (5 yêu cầu/giây), **Burst** (10 yêu cầu), và **Quota** (1000 yêu cầu/ngày), sẵn sàng để liên kết với API `student` và stage `prod`.

> **Bước tiếp theo**: Chuyển đến [Tạo phương thức GET để truy xuất dữ liệu](/4-creating-a-restful-api/4.4-creating-a-get-method/) để tiếp tục!