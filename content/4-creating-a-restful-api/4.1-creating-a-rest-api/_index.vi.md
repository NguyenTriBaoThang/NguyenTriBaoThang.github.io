---
title: "Tạo REST API mới trên API Gateway"
date: 2023-10-25
weight: 1
chapter: false
pre: "<b>4.1 </b>"
---

> **Mục tiêu**: Tạo một REST API mới trong AWS API Gateway với tên `student` và loại endpoint **Edge-optimized**, để tích hợp với các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`) và giao diện web (chạy trên CloudFront). API này sẽ cung cấp các endpoint để truy xuất, lưu trữ, và sao lưu dữ liệu sinh viên, đồng thời được bảo mật bằng API Key và hỗ trợ CORS.

---

## Tổng Quan về REST API trong API Gateway

- AWS API Gateway là dịch vụ serverless cho phép tạo các API RESTful hoặc HTTP, kết nối giao diện web với các dịch vụ backend như Lambda, DynamoDB, hoặc S3.  
- API `student` sẽ bao gồm các endpoint:  
  - **GET /students**: Gọi hàm `getStudentData` để lấy danh sách sinh viên từ bảng DynamoDB `studentData`.  
  - **POST /students**: Gọi hàm `insertStudentData` để lưu thông tin sinh viên và gửi email xác nhận qua SES.  
  - **POST /backup**: Gọi hàm `BackupDynamoDBAndSendEmail` để sao lưu dữ liệu vào S3 và gửi email thông báo.  
- **Edge-optimized** endpoint sử dụng mạng CloudFront để giảm độ trễ, phù hợp với giao diện web phân phối qua CloudFront.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành các bước ở mục 3 (tạo các hàm Lambda `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, SES email xác minh). Đảm bảo tài khoản AWS đã sẵn sàng và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console**  
   - Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS của bạn.  
   - Trong thanh tìm kiếm ở đầu trang, nhập **API Gateway** và chọn dịch vụ **Amazon API Gateway** để vào giao diện quản lý.  
   - Kiểm tra vùng AWS: Đảm bảo bạn đang làm việc trong vùng AWS chính (ví dụ: `us-east-1`), kiểm tra vùng ở góc trên bên phải AWS Console. Vùng này phải khớp với các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`), bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, và SES.  

     ![Giao diện AWS Console với thanh tìm kiếm API Gateway.](/images/5-creating-a-restful-api/4.1-creating-a-rest-api/creating-a-rest-api-01.png)
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm API Gateway.*

2. **Điều Hướng Đến Mục APIs**  
   - Trong giao diện chính của Amazon API Gateway, nhìn vào menu điều hướng bên trái.  
   - Chọn **APIs** để xem danh sách các API hiện có. Nếu bạn chưa tạo API nào, danh sách sẽ trống.  
   - Giao diện sẽ hiển thị các tùy chọn để tạo hoặc quản lý API.  

     ![Menu điều hướng với tùy chọn APIs.](/images/5-creating-a-restful-api/4.1-creating-a-rest-api/creating-a-rest-api-02.png)
     *Hình 2: Menu điều hướng với tùy chọn APIs.*

3. **Khởi Tạo Quá Trình Tạo API**  
   - Trong giao diện **APIs**, nhấn nút **Create API (Tạo API)** ở góc trên bên phải để bắt đầu cấu hình API mới.  
   - Nếu bạn thấy tùy chọn **REST API** ngay lập tức, nhảy sang bước 4. Nếu không, giao diện sẽ liệt kê các loại API (REST API, HTTP API, WebSocket API).  

     ![Nút Create API trong giao diện APIs.](/images/5-creating-a-restful-api/4.1-creating-a-rest-api/creating-a-rest-api-03.png)
     *Hình 3: Nút Create API trong giao diện APIs.*

4. **Chọn REST API và Build**  
   - Trong giao diện **Create API**, tìm phần **REST API** (không phải REST API Private hoặc HTTP API).  
   - Nhấn **Build** bên dưới **REST API** để bắt đầu tạo API RESTful.  
   - **Lưu ý về REST API**:  
     - REST API hỗ trợ các tính năng như API Key, CORS, và tích hợp Lambda Proxy, phù hợp với hệ thống này.  
     - So sánh với HTTP API (nhẹ hơn, chi phí thấp hơn) và REST API Private (chỉ truy cập trong VPC), REST API là lựa chọn tốt nhất cho ứng dụng công khai tích hợp với CloudFront.  

     ![Giao diện chọn REST API và nhấn Build.](/images/5-creating-a-restful-api/4.1-creating-a-rest-api/creating-a-rest-api-04.png)
     *Hình 4: Giao diện chọn REST API và nhấn Build.*

5. **Cấu Hình Chi Tiết API**  
   - Trong mục **API Details**:  
     - Chọn **New API** để tạo API mới từ đầu.  
     - **API name**: Nhập chính xác `student` (khác với `StudentManagementAPI` ở mục 4 trước đó, tôi sẽ sử dụng `student` như yêu cầu).  
     - **Description**: Nhập *REST API cho hệ thống quản lý sinh viên, tích hợp với Lambda và CloudFront*.  
     - **API endpoint Type**: Chọn **Edge-optimized**.  
       - **Giải thích**:  
         - **Edge-optimized**: API được phân phối qua mạng CloudFront, sử dụng các edge locations để giảm độ trễ cho người dùng toàn cầu. Phù hợp với giao diện web chạy trên CloudFront.  
         - **Regional**: API chỉ phục vụ trong một vùng AWS, phù hợp nếu không cần tối ưu độ trễ toàn cầu.  
         - **Private**: Chỉ truy cập trong VPC, không phù hợp với ứng dụng công khai.  
     - Giữ các thiết lập khác ở giá trị mặc định.  

    ![Giao diện cấu hình chi tiết API.](/images/5-creating-a-restful-api/4.1-creating-a-rest-api/creating-a-rest-api-05.png)
     *Hình 5: Giao diện cấu hình chi tiết API.*

   - Nhấn **Create API** để tạo.  

     ![Nhấn nút Create API.](/images/5-creating-a-restful-api/4.1-creating-a-rest-api/creating-a-rest-api-06.png)
     - *Hình 6: Nhấn nút Create API.*

6. **Kiểm Tra Trạng Thái Tạo API**  
   - Sau khi nhấn **Create API**, bạn sẽ được chuyển đến trang quản lý API `student`.  
   - Giao diện sẽ hiển thị thông báo: _"Successfully created REST API ‘student’."_  
   - Nếu không thấy thông báo hoặc gặp lỗi:  
     - Kiểm tra quyền IAM của tài khoản AWS có bao gồm `apigateway:POST` để tạo API.  
     - Đảm bảo bạn đã chọn **REST API** và **Edge-optimized** đúng cách.  
   - Trong menu bên trái, chọn **Resources** để bắt đầu cấu hình các resource và method (sẽ thực hiện ở các mục 4.4, 4.5, 4.6).  

   ![Trang quản lý API student sau khi tạo.](/images/5-creating-a-restful-api/4.1-creating-a-rest-api/creating-a-rest-api-07.png)
   - *Hình 7: Trang quản lý API student sau khi tạo.*

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Tên API** | Tên `student` phải được nhập chính xác, vì nó sẽ xuất hiện trong URL Invoke (ví dụ: `https://api-id.execute-api.us-east-1.amazonaws.com/prod`). |
| **Edge-optimized vs Regional** | **Edge-optimized** phù hợp với hệ thống này vì giao diện web sử dụng CloudFront. URL Invoke sẽ có định dạng sử dụng CloudFront edge locations. Nếu bạn cần tích hợp với một domain tùy chỉnh (ví dụ: `api.system.edu.vn`), đảm bảo cấu hình domain trong API Gateway và CloudFront sau khi tạo API. |
| **Vùng AWS** | Đảm bảo vùng `us-east-1` khớp với các hàm Lambda, bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, và SES. Nếu sử dụng vùng khác (ví dụ: `us-west-2`), bạn cần điều chỉnh khi cấu hình tích hợp Lambda (các mục 4.4, 4.5, 4.6). |
| **Xử lý lỗi** | Nếu gặp lỗi _"AccessDenied"_, kiểm tra quyền IAM của tài khoản AWS. Nếu API không hiển thị, làm mới trang hoặc kiểm tra lại vùng AWS. |
| **Tối ưu hóa** | Sau khi tạo API, bạn có thể thêm mô tả chi tiết hơn trong **Settings** (menu bên trái) hoặc bật logging API Gateway để giám sát: <br> - Vào **Settings** > **CloudWatch Logs** > Chọn **Enable CloudWatch Logs** và đặt mức log (ví dụ: INFO). <br> - Điều này giúp gỡ lỗi khi tích hợp với Lambda hoặc giao diện web. |
| **Kiểm tra sớm** | Sau khi tạo API, xác minh API xuất hiện trong danh sách **APIs** trước khi cấu hình resource và method. |

> **Mẹo thực tiễn**: Xác minh API `student` xuất hiện trong danh sách APIs và kiểm tra URL Invoke sau khi triển khai (mục 4.8) để đảm bảo API sẵn sàng tích hợp.

---

## Kết Luận

REST API `student` đã được tạo thành công trong AWS API Gateway với loại endpoint **Edge-optimized**, sẵn sàng để cấu hình các resource và method trong các bước tiếp theo.

> **Bước tiếp theo**: Chuyển đến [Tạo API Key để bảo vệ truy cập](/4-creating-a-restful-api/4.2-creating-an-api-key/) để tiếp tục!