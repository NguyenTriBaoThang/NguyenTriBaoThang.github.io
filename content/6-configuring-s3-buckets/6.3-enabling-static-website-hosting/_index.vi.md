---
title: "Bật Tính Năng Static Website Hosting"
date: 2025-07-09
weight: 3
chapter: false
pre: "<b>6.3. </b>"
---

> **Mục tiêu**: Bật tính năng **Static Website Hosting** trên S3 Bucket `student-management-website-2025` để phục vụ các tệp tĩnh (`index.html`, `styles.css`, `scripts.js` từ mục 6.2) dưới dạng website tĩnh. Điều này cung cấp endpoint HTTP (VD: http://student-management-website-2025.s3-website-us-east-1.amazonaws.com) để truy cập giao diện, chuẩn bị phân phối qua CloudFront (mục 7) với HTTPS và hiệu suất cao. Giao diện gọi các endpoint API **GET /students**, **POST /students**, và **POST /backup** (mục 4.8) sử dụng **Invoke URL** (VD: https://abc123.execute-api.us-east-1.amazonaws.com/prod) và `StudentApiKey` (mục 4.2) với CORS (mục 4.7).

---

## Tổng Quan về Static Website Hosting

- **Vai trò của Static Website Hosting**:  
  - Biến bucket `student-management-website-2025` thành máy chủ web tĩnh, cung cấp endpoint HTTP (VD: http://student-management-website-2025.s3-website-us-east-1.amazonaws.com).  
  - Xử lý yêu cầu HTTP GET cho các tệp tĩnh (`index.html`, `styles.css`, `scripts.js`).  
  - Chỉ định `index.html` làm **Index document** để hiển thị trang chính khi truy cập endpoint gốc.  
- **Tích hợp với hệ thống**:  
  - Giao diện web gọi API `student` (stage `prod`, mục 4.8) để:  
    - **POST /students**: Lưu bản ghi vào DynamoDB `studentData` và gửi email xác nhận qua SES.  
    - **GET /students**: Hiển thị dữ liệu trong bảng.  
    - **POST /backup**: Tạo tệp backup trong S3 Bucket `student-backup-20250706` (mục 2.4, 6.5) và gửi email thông báo qua SES.  
  - **Bucket Policy** (mục 6.4) cho phép truy cập công khai (`s3:GetObject`) để CloudFront truy xuất nội dung.  
  - CloudFront (mục 7) sử dụng endpoint S3 làm Origin để cung cấp HTTPS và tăng tốc độ tải.  
  - CORS được cấu hình (mục 4.7) để hỗ trợ yêu cầu từ domain CloudFront (VD: https://d12345678.cloudfront.net).  
- **Lý do chọn `index.html` làm Index document**:  
  - `index.html` là tệp chính chứa giao diện (biểu mẫu, bảng, nút chức năng) được tải lên ở mục 6.2.  
  - Khi truy cập endpoint gốc, S3 tự động phục vụ `index.html`.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành mục 6.1 (tạo bucket `student-management-website-2025`), mục 6.2 (tải lên `index.html`, `styles.css`, `scripts.js`), mục 5 (xây dựng giao diện web), mục 4.1 (tạo API `student`), mục 4.2 (tạo API Key `StudentApiKey`), mục 4.3 (tạo Usage Plan `StudentUsagePlan`), mục 4.4 (tạo phương thức **GET /students**), mục 4.5 (tạo phương thức **POST /students**), mục 4.6 (tạo resource `/backup` và phương thức **POST /backup**), mục 4.7 (kích hoạt CORS), mục 4.8 (triển khai API lên stage `prod`), mục 4.9 (gắn `StudentApiKey` vào `StudentUsagePlan`), mục 3 (tạo các hàm Lambda `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, bảng DynamoDB `studentData`, bucket `student-backup-20250706`, SES email xác minh). Đảm bảo tài khoản AWS có quyền `s3:PutBucketWebsite` và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console**  
   - Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS của bạn.  
   - Trong thanh tìm kiếm ở đầu trang, nhập **S3** và chọn dịch vụ **Amazon S3** để vào giao diện quản lý bucket.  
   - Kiểm tra vùng AWS: Đảm bảo bạn đang làm việc trong vùng **us-east-1** (US East (N. Virginia)) để đồng bộ với bucket `student-management-website-2025`, API `student`, các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`), bảng DynamoDB `studentData`, bucket `student-backup-20250706`, và SES. Vùng được hiển thị ở góc trên bên phải AWS Console.  
   
     ![Giao diện AWS Console với thanh tìm kiếm S3.](/images/6-configuring-s3-buckets/6.3-enabling-static-website-hosting/enabling-static-website-hosting-01.png)
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm S3.*

2. **Chọn Bucket `student-management-website-2025`**  
   - Trong giao diện chính của **Amazon S3 > Buckets**, tìm và chọn bucket `student-management-website-2025` (tạo ở mục 6.1).  
   - Nếu không thấy bucket:  
     - Kiểm tra vùng AWS (`us-east-1`) và làm mới trang.  
     - Xác minh bucket đã được tạo với tên chính xác (tên bucket là duy nhất toàn cầu, có thể bạn đã dùng tên khác như `student-management-website-20250706-abc123`).  
   - Nhấn vào tên bucket để vào giao diện quản lý bucket.  

     ![Chọn bucket student-management-website-2025.](/images/6-configuring-s3-buckets/6.3-enabling-static-website-hosting/enabling-static-website-hosting-02.png)
     *Hình 2: Chọn bucket student-management-website-2025.*

3. **Truy Cập Tab Properties**  
   - Trong giao diện của bucket `student-management-website-2025`, chọn tab **Properties** (thường nằm ở đầu trang, bên cạnh Objects, Permissions, v.v.).  
   - Cuộn xuống phần **Static website hosting** để xem trạng thái hiện tại (mặc định là **Disabled**).  

     ![Tab Properties và phần Static website hosting.](/images/6-configuring-s3-buckets/6.3-enabling-static-website-hosting/enabling-static-website-hosting-03.png)
     *Hình 3: Tab Properties và phần Static website hosting.*

4. **Chỉnh Sửa Static Website Hosting**  
   - Trong phần **Static website hosting**, nhấn nút **Edit** để mở giao diện cấu hình.  
   - Kiểm tra trước khi chỉnh sửa: Đảm bảo các tệp `index.html`, `styles.css`, `scripts.js` đã được tải lên bucket (mục 6.2), vì **Static Website Hosting** yêu cầu tệp `index.html` tồn tại để hoạt động đúng.  

     ![Nhấn Edit trong Static website hosting.](/images/6-configuring-s3-buckets/6.3-enabling-static-website-hosting/enabling-static-website-hosting-04.png)
     *Hình 4: Nhấn Edit trong Static website hosting.*

5. **Cấu Hình Static Website Hosting**  
   - Trong giao diện **Edit static website hosting**, nhập các thông tin sau:  
     - **Static website hosting**: Chọn **Enable** để bật tính năng.  
     - **Hosting type**: Chọn **Host a static website** (phù hợp cho giao diện tĩnh của ứng dụng).  
       - **Lưu ý**: Không chọn **Redirect requests for an object** (dùng cho chuyển hướng, không phù hợp ở đây).  
     - **Index document**: Nhập `index.html` (tệp chính của giao diện web, chứa biểu mẫu và bảng sinh viên).  
       - **Lý do**: Khi truy cập endpoint gốc của bucket, S3 sẽ phục vụ `index.html` làm trang mặc định.  
     - **Error document** (Tùy chọn):  
       - Nhập `index.html` để chuyển hướng mọi lỗi (VD: 404 Not Found) về trang chính.  
       - **Lý do**: Đảm bảo người dùng luôn thấy giao diện chính, ngay cả khi truy cập đường dẫn không tồn tại.  
       - Nếu muốn trang lỗi tùy chỉnh, tải lên tệp `error.html` (mục 6.2) và nhập tên tệp ở đây.  
   - Kiểm tra cấu hình: Xác minh **Enable** được chọn, **Hosting type** là **Host a static website**, và **Index document** là `index.html`.  

     ![Cấu hình Static website hosting.](/images/6-configuring-s3-buckets/6.3-enabling-static-website-hosting/enabling-static-website-hosting-05.png)
     *Hình 5: Cấu hình Static website hosting.*

6. **Lưu Thay Đổi**  
   - Nhấn **Save changes** để áp dụng cấu hình.  
   - Kết quả mong đợi: AWS S3 hiển thị thông báo _"Successfully edited static website hosting"_.  

     ![Nhấn Save changes.](/images/6-configuring-s3-buckets/6.3-enabling-static-website-hosting/enabling-static-website-hosting-06.png)
     *Hình 6: Nhấn Save changes.*  
   - Trong tab **Properties > Static website hosting**, bạn sẽ thấy:  
     - **Status**: Enabled.  
     - **Bucket website endpoint**: URL dạng http://student-management-website-2025.s3-website-us-east-1.amazonaws.com.  
   - Sao chép **Bucket website endpoint** để kiểm tra.  

     ![Thông báo trạng thái và Bucket website endpoint.](/images/6-configuring-s3-buckets/6.3-enabling-static-website-hosting/enabling-static-website-hosting-08.png)
     *Hình 7: Thông báo trạng thái và Bucket website endpoint.*

7. **Kiểm Tra Static Website Hosting**  
   - Mở trình duyệt và truy cập **Bucket website endpoint** (VD: http://student-management-website-2025.s3-website-us-east-1.amazonaws.com).  
   - Kết quả mong đợi:  
     - Giao diện web hiển thị với biểu mẫu nhập liệu, bảng sinh viên, và các nút chức năng (Lưu, Xem, Backup).  
     - Các tệp `styles.css` và `scripts.js` được tải đúng, giao diện sử dụng Tailwind CSS và font Poppins hiển thị chính xác.  

     ![Giao diện web hiển thị qua endpoint S3.](/images/6-configuring-s3-buckets/6.3-enabling-static-website-hosting/enabling-static-website-hosting-09.png)
     *Hình 8: Giao diện web hiển thị qua endpoint S3.*  
     
   - **Lưu ý**:  
     - Các yêu cầu API (**GET /students**, **POST /students**, **POST /backup**) có thể gặp lỗi CORS vì endpoint S3 sử dụng HTTP và chưa tích hợp với CloudFront. Điều này sẽ được khắc phục khi cấu hình CloudFront (mục 7) và CORS trong API Gateway (mục 4.7).  
     - Endpoint S3 chỉ hỗ trợ HTTP, không hỗ trợ HTTPS. CloudFront sẽ cung cấp HTTPS và tăng tốc độ tải.  
   - **Xử lý lỗi**:  
     - **Lỗi 403 Forbidden**:  
       - Kiểm tra **Bucket Policy** (mục 6.4) đã cho phép `s3:GetObject` công khai.  
       - Đảm bảo **Block all public access** đã bỏ chọn (mục 6.1).  
     - **Lỗi 404 Not Found**:  
       - Xác minh `index.html` đã được tải lên bucket (mục 6.2) và nằm ở thư mục gốc.  
       - Kiểm tra đường dẫn trong `index.html` cho `styles.css` và `scripts.js` (VD: <link href="styles.css">, <script src="scripts.js">).  
     - **Giao diện hiển thị sai**:  
       - Mở **Developer Tools > Console** trong trình duyệt để kiểm tra lỗi (VD: tệp CSS/JS không tải).  
       - Xác minh các tệp được tải lên đúng (mục 6.2) và không bị hỏng.  
     - **Lỗi "AccessDenied"**:  
       - Kiểm tra vai trò IAM của tài khoản có quyền `s3:PutBucketWebsite`.  

---

## Lưu Ý Quan Trọng

| Yếu Tố | Chi Tiết |
|--------|----------|
| Bảo mật | Hiện tại, bucket sử dụng quyền công khai (`s3:GetObject`). Sử dụng CloudFront **Origin Access Identity (OAI)** (mục 6.4) để hạn chế truy cập trực tiếp vào S3. Tránh nhúng `StudentApiKey` trong `scripts.js`; sử dụng AWS Secrets Manager hoặc CloudFront Functions: <br> function handler(event) { var request = event.request; request.headers['x-api-key'] = { value: 'xxxxxxxxxxxxxxxxxxxx' }; return request; } |
| Tối ưu hóa | Đảm bảo `styles.css`, `scripts.js` đã nén (mục 6.2). Bật **S3 Access Logs**: Trong S3 > student-management-website-2025 > Properties > Server access logging, chọn **Enable**, chỉ định bucket log (VD: student-web-logs-20250706). Sử dụng AWS CLI: <br> aws s3api put-bucket-website --bucket student-management-website-2025 --website-configuration '{"IndexDocument":{"Suffix":"index.html"},"ErrorDocument":{"Key":"index.html"}}' |
| Tích hợp với hệ thống | Cấu hình **Bucket Policy** (mục 6.4) để cho phép CloudFront truy xuất. Tạo CloudFront phân phối (mục 7) với Origin là **Bucket website endpoint**, **Default root object**: `index.html`, **Viewer protocol policy**: Redirect HTTP to HTTPS. Cập nhật CORS trong API Gateway (mục 4.7) với `Access-Control-Allow-Origin: https://d12345678.cloudfront.net`. |
| Kiểm tra tích hợp | Truy cập **Bucket website endpoint** để kiểm tra giao diện. Sau khi cấu hình CloudFront, truy cập CloudFront URL (https://d12345678.cloudfront.net) và kiểm tra: **POST /students** (lưu bản ghi, gửi email SES), **GET /students** (hiển thị bảng), **POST /backup** (tạo tệp trong `student-backup-20250706`, gửi email). Sử dụng **Developer Tools > Network** để kiểm tra yêu cầu API. |
| Xử lý lỗi | **403 Forbidden**: Kiểm tra **Bucket Policy** (mục 6.4) và **Block all public access** (mục 6.1). **404 Not Found**: Xác minh `index.html` ở thư mục gốc, đường dẫn trong `index.html` đúng (<link href="styles.css">, <script src="scripts.js">). **Giao diện sai**: Kiểm tra **Developer Tools > Console**. **AccessDenied**: Kiểm tra quyền IAM (`s3:PutBucketWebsite`). |

> **Mẹo thực tiễn**: Kiểm tra endpoint S3 trước khi tích hợp CloudFront. Nếu gặp lỗi CORS, xác minh cấu hình CORS trong API Gateway (mục 4.7). Sử dụng AWS CLI để tự động hóa cấu hình.

---

## Kết Luận

Tính năng **Static Website Hosting** đã được bật trên bucket `student-management-website-2025`, cung cấp endpoint HTTP để phục vụ giao diện web. Bucket sẵn sàng tích hợp với CloudFront (mục 7) để hỗ trợ HTTPS.

> **Bước tiếp theo**: Chuyển đến [Cấu hình Bucket Policy để cho phép truy cập công khai](/6-configuring-s3-buckets/6.4-setting-bucket-policy-for-public-access/) để tiếp tục cấu hình!