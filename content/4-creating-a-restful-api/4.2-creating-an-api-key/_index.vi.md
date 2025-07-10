---
title: "Tạo API Key để bảo vệ truy cập"
date: 2025-07-09
weight: 2
chapter: false
pre: "<b>4.2. </b>"
---

> **Mục tiêu**: Tạo một API Key có tên `StudentApiKey` trong AWS API Gateway để bảo vệ các endpoint của API `student` (tạo ở mục 4.1), đảm bảo chỉ các yêu cầu từ giao diện web (chạy trên CloudFront) hoặc client được cấp key hợp lệ mới có thể truy cập. API Key sẽ được sử dụng trong header `x-api-key` khi gọi các endpoint (`GET /students`, `POST /students`, `POST /backup`) và sẽ được liên kết với Usage Plan (mục 4.3) để quản lý giới hạn truy cập.

---

## Tổng Quan về API Key trong API Gateway

- API Key là một chuỗi ký tự dùng để xác thực các yêu cầu gửi đến API Gateway, ngăn chặn truy cập trái phép.  
- API Key được gửi trong header `x-api-key` của mỗi yêu cầu HTTP (ví dụ: `GET https://api-id.execute-api.us-east-1.amazonaws.com/prod/students`).  
- Trong hệ thống này, `StudentApiKey` sẽ bảo mật các endpoint tích hợp với các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`).  
- API Key sẽ được tích hợp vào giao diện web (sử dụng Tailwind CSS, chạy trên CloudFront) để gọi API một cách an toàn.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành mục 4.1 (tạo API `student`) và mục 3 (tạo các hàm Lambda `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, SES email xác minh). Đảm bảo tài khoản AWS đã sẵn sàng và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console**  
   - Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS của bạn.  
   - Trong thanh tìm kiếm ở đầu trang, nhập **API Gateway** và chọn dịch vụ **Amazon API Gateway** để vào giao diện quản lý.  
   - Kiểm tra vùng AWS: Đảm bảo bạn đang làm việc trong vùng AWS chính (ví dụ: `us-east-1`), kiểm tra vùng ở góc trên bên phải AWS Console. Vùng này phải khớp với API `student` (tạo ở mục 4.1) và các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`).  

     ![Giao diện AWS Console với thanh tìm kiếm API Gateway.](/images/5-creating-a-restful-api/4.2-creating-an-api-key/creating-an-api-key-01.png)
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm API Gateway.*

2. **Điều Hướng Đến Mục API Keys**  
   - Trong giao diện chính của Amazon API Gateway, nhìn vào menu điều hướng bên trái.  
   - Chọn **API Keys** để xem danh sách các API Key hiện có. Nếu bạn chưa tạo key nào, danh sách sẽ trống.  
   - Giao diện sẽ hiển thị các tùy chọn để tạo hoặc quản lý API Key.  

     ![Menu điều hướng với tùy chọn API Keys.](/images/5-creating-a-restful-api/4.2-creating-an-api-key/creating-an-api-key-02.png)
     *Hình 2: Menu điều hướng với tùy chọn API Keys.*

3. **Khởi Tạo Quá Trình Tạo API Key**  
   - Trong giao diện **API Keys**, nhấn nút **Create API Key (Tạo API Key)** ở góc trên bên phải để bắt đầu cấu hình key mới.  

     ![Nút Create API Key trong giao diện API Keys.](/images/5-creating-a-restful-api/4.2-creating-an-api-key/creating-an-api-key-03.png)
     *Hình 3: Nút Create API Key trong giao diện API Keys.*

4. **Cấu Hình API Key**  
   - Trong mục **Create API Key**:  
     - **Name**: Nhập chính xác `StudentApiKey`. Tên này giúp bạn dễ dàng nhận diện key khi liên kết với Usage Plan.  
     - **Description**: Nhập *API Key để bảo vệ truy cập vào StudentManagementAPI* (hoặc mô tả tương tự để rõ ràng mục đích).  
     - **API Key**: Chọn **Auto Generate** để AWS tạo một chuỗi ngẫu nhiên, đảm bảo tính bảo mật.  
       - **Lưu ý**: Bạn có thể nhập key tùy chỉnh, nhưng **Auto Generate** được khuyến nghị để tránh key dễ đoán.  
     - **Enabled**: Đảm bảo tùy chọn này được chọn để key có thể sử dụng ngay sau khi tạo.  
   - Nhấn **Save** để tạo API Key.  

     ![Giao diện cấu hình API Key.](/images/5-creating-a-restful-api/4.2-creating-an-api-key/creating-an-api-key-04.png)
     *Hình 4: Giao diện cấu hình API Key.*

5. **Kiểm Tra Trạng Thái và Sao Chép API Key**  
   - Sau khi nhấn **Save**, bạn sẽ thấy thông báo: _"Successfully created API Key ‘StudentApiKey’."_  
   - Trong danh sách **API Keys**, chọn `StudentApiKey` để xem chi tiết.  
   - Nhấn **Show** bên cạnh **API Key** để hiển thị giá trị key (ví dụ: `xxxxxxxxxxxxxxxxxxxx`).  
   - **Sao chép API Key**:  
     - Sao chép giá trị key và lưu ở nơi an toàn (ví dụ: tệp bảo mật cục bộ, AWS Secrets Manager, hoặc trình quản lý mật khẩu).  
     - **Lưu ý quan trọng**: API Key chỉ hiển thị một lần ngay sau khi tạo. Nếu mất, bạn phải tạo key mới và cập nhật trong Usage Plan (mục 4.3) và giao diện web.  
   - API Key này sẽ được sử dụng trong giao diện web để gọi các endpoint (`GET /students`, `POST /students`, `POST /backup`) bằng cách thêm vào header `x-api-key`.  

     ![Thông báo thành công và chi tiết API Key.](/images/5-creating-a-restful-api/4.2-creating-an-api-key/creating-an-api-key-05.png)
     *Hình 5: Thông báo thành công và chi tiết API Key.*

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Bảo mật API Key** | Không nhúng API Key trực tiếp trong mã JavaScript của giao diện web (chạy trên CloudFront). Thay vào đó, sử dụng biến môi trường hoặc AWS Secrets Manager để lưu trữ và truy xuất key an toàn. <br> - Vào **AWS Secrets Manager** > **Store a new secret** > Chọn **Other type of secret** > Nhập API Key. <br> - Đặt tên bí mật (ví dụ: `student-api-key`) và truy xuất trong mã giao diện web thông qua AWS SDK. |
| **Vùng AWS** | API Key hoạt động trên toàn bộ tài khoản AWS, không bị giới hạn bởi vùng. Tuy nhiên, đảm bảo API `student` và các hàm Lambda đều ở cùng vùng (`us-east-1`) để tránh lỗi tích hợp. |
| **Xử lý lỗi** | Nếu không thấy thông báo thành công hoặc gặp lỗi _"AccessDenied"_: <br> - Kiểm tra quyền IAM của tài khoản AWS có bao gồm `apigateway:POST` để tạo API Key. <br> - Đảm bảo bạn đang ở đúng vùng AWS (`us-east-1`). <br> Nếu API Key không hiển thị, làm mới trang hoặc kiểm tra lại danh sách **API Keys**. |
| **Tối ưu hóa** | - Sau khi tạo, liên kết API Key với Usage Plan (mục 4.3) để áp dụng giới hạn truy cập (rate limiting, quota). <br> - Cân nhắc sử dụng AWS WAF với API Gateway để bảo vệ thêm khỏi các cuộc tấn công (ví dụ: DDoS). <br> - Nếu cần nhiều API Key (cho các client khác nhau), tạo thêm key và quản lý trong cùng Usage Plan. |
| **Kiểm tra sớm** | - Sau khi tạo API Key, xác minh key xuất hiện trong danh sách **API Keys** và giá trị key được sao chép an toàn. <br> - Kiểm tra key bằng cách gọi thử API (sau khi cấu hình method và deploy ở các mục 4.4–4.8) sử dụng Postman hoặc curl: <br> `curl -X GET https://api-id.execute-api.us-east-1.amazonaws.com/prod/students -H "x-api-key: xxxxxxxxxxxxxxxxxxxx"` |
| **Kiểm tra tích hợp với giao diện web** | - Sau khi tạo API Key, nhúng key này vào giao diện web (sử dụng Tailwind CSS, chạy trên CloudFront) để gọi các endpoint. <br> - Đảm bảo API Key được gửi trong header `x-api-key` khi gọi các endpoint (`GET /students`, `POST /students`, `POST /backup`). |

> **Mẹo thực tiễn**: Lưu API Key an toàn ngay sau khi tạo và kiểm tra tích hợp với một yêu cầu thử (sử dụng Postman hoặc curl) trước khi nhúng vào giao diện web.

---

## Kết Luận

API Key `StudentApiKey` đã được tạo thành công trong AWS API Gateway, sẵn sàng để liên kết với Usage Plan và bảo vệ các endpoint của API `student`.

> **Bước tiếp theo**: Chuyển đến [Thiết lập Usage Plan (Kế hoạch sử dụng)](/4-creating-a-restful-api/4.3-creating-a-usage-plan/) để tiếp tục!