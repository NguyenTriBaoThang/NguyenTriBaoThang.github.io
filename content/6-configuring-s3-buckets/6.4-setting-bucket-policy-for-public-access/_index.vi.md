---
title: "Cấu Hình Bucket Policy để Cho Phép Truy Cập Công Khai"
date: 2023-10-25
weight: 4
chapter: false
pre: "<b>6.4. </b>"
---

> **Mục tiêu**: Cấu hình **Bucket Policy** cho S3 Bucket `student-management-website-2025` để cho phép truy cập công khai (`s3:GetObject`) tới các tệp tĩnh (`index.html`, `styles.css`, `scripts.js` từ mục 6.2). Điều này đảm bảo giao diện web tĩnh (được bật **Static Website Hosting** ở mục 6.3) có thể được truy cập qua endpoint S3 hoặc CloudFront (mục 7). **Bucket Policy** cho phép mọi người (`Principal: *`) đọc các tệp, hỗ trợ tích hợp với API `student` (stage `prod`, mục 4.8) để gọi các endpoint **GET /students**, **POST /students**, và **POST /backup** với bảo mật API Key (`StudentApiKey`, mục 4.2) và CORS (mục 4.7).

---

## Tổng Quan về Bucket Policy

- **Vai trò của Bucket Policy**:  
  - Cấp quyền truy cập công khai (`s3:GetObject`) để trình duyệt hoặc CloudFront đọc các tệp tĩnh (`index.html`, `styles.css`, `scripts.js`).  
  - Đảm bảo endpoint **Static Website Hosting** (VD: http://student-management-website-2025.s3-website-us-east-1.amazonaws.com) phục vụ giao diện web đúng cách.  
  - Chuẩn bị cho tích hợp với CloudFront, cung cấp HTTPS và hiệu suất cao.  
- **Tích hợp với hệ thống**:  
  - Giao diện web gọi API `student` (mục 4.8) sử dụng **Invoke URL** (VD: https://abc123.execute-api.us-east-1.amazonaws.com/prod) và `StudentApiKey` trong header `x-api-key`.  
  - Các chức năng bao gồm:  
    - **POST /students**: Lưu bản ghi vào DynamoDB `studentData` và gửi email xác nhận qua SES.  
    - **GET /students**: Hiển thị dữ liệu trong bảng.  
    - **POST /backup**: Tạo tệp backup trong S3 Bucket `student-backup-20250706` (mục 2.4, 6.5) và gửi email thông báo qua SES.  
  - CORS được cấu hình (mục 4.7) để hỗ trợ yêu cầu từ domain CloudFront (VD: https://d12345678.cloudfront.net).  
- **Lý do cấp quyền công khai**:  
  - **Static Website Hosting** yêu cầu các tệp trong bucket có thể truy cập công khai để trình duyệt hoặc CloudFront tải nội dung.  
  - Quyền `s3:GetObject` được cấp cho `Principal: *` (mọi người) để đơn giản hóa, nhưng có thể giới hạn với CloudFront **OAI** (xem **Lưu ý**) để tăng bảo mật.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành mục 6.1 (tạo bucket `student-management-website-2025`), mục 6.2 (tải lên `index.html`, `styles.css`, `scripts.js`), mục 6.3 (bật **Static Website Hosting**), mục 5 (xây dựng giao diện web), mục 4.1 (tạo API `student`), mục 4.2 (tạo API Key `StudentApiKey`), mục 4.3 (tạo Usage Plan `StudentUsagePlan`), mục 4.4 (tạo phương thức **GET /students**), mục 4.5 (tạo phương thức **POST /students**), mục 4.6 (tạo resource `/backup` và phương thức **POST /backup**), mục 4.7 (kích hoạt CORS), mục 4.8 (triển khai API lên stage `prod`), mục 4.9 (gắn `StudentApiKey` vào `StudentUsagePlan`), mục 3 (tạo các hàm Lambda `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, bảng DynamoDB `studentData`, bucket `student-backup-20250706`, SES email xác minh). Đảm bảo tài khoản AWS có quyền `s3:PutBucketPolicy` và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console**  
   - Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS của bạn.  
   - Trong thanh tìm kiếm ở đầu trang, nhập **S3** và chọn dịch vụ **Amazon S3** để vào giao diện quản lý bucket.  
   - Kiểm tra vùng AWS: Đảm bảo bạn đang làm việc trong vùng **us-east-1** (US East (N. Virginia)) để đồng bộ với bucket `student-management-website-2025`, API `student`, các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`), bảng DynamoDB `studentData`, bucket `student-backup-20250706`, và SES. Vùng được hiển thị ở góc trên bên phải AWS Console.  
     ![Giao diện AWS Console với thanh tìm kiếm S3.](/images/6-configuring-s3-buckets/6.4-setting-bucket-policy-for-public-access/setting-bucket-policy-for-public-access-01.png)
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm S3.*

2. **Chọn Bucket `student-management-website-2025`**  
   - Trong giao diện chính của **Amazon S3 > Buckets**, tìm và chọn bucket `student-management-website-2025` (tạo ở mục 6.1).  
   - Nếu không thấy bucket:  
     - Kiểm tra vùng AWS (`us-east-1`) và làm mới trang.  
     - Xác minh bucket đã được tạo với tên chính xác (tên bucket là duy nhất toàn cầu, có thể bạn đã dùng tên khác như `student-management-website-20250706-abc123`).  
   - Nhấn vào tên bucket để vào giao diện quản lý bucket.  
     ![Chọn bucket student-management-website-2025.](/images/6-configuring-s3-buckets/6.4-setting-bucket-policy-for-public-access/setting-bucket-policy-for-public-access-02.png)
     *Hình 2: Chọn bucket student-management-website-2025.*

3. **Truy Cập Tab Permissions**  
   - Trong giao diện của bucket `student-management-website-2025`, chọn tab **Permissions** (thường nằm ở đầu trang, bên cạnh Objects, Properties, v.v.).  
   - Cuộn xuống phần **Bucket policy** để xem trạng thái hiện tại (mặc định là trống nếu chưa cấu hình).  
     ![Tab Permissions và phần Bucket policy.](/images/6-configuring-s3-buckets/6.4-setting-bucket-policy-for-public-access/setting-bucket-policy-for-public-access-03.png)
     *Hình 3: Tab Permissions và phần Bucket policy.*

4. **Chỉnh Sửa Bucket Policy**  
   - Trong phần **Bucket policy**, nhấn nút **Edit** để mở giao diện chỉnh sửa.  
   - Kiểm tra trước khi chỉnh sửa:  
     - Đảm bảo **Block all public access** đã bỏ chọn (mục 6.1) để cho phép cấu hình quyền công khai.  
     - Xác minh các tệp `index.html`, `styles.css`, `scripts.js` đã được tải lên (mục 6.2) và **Static Website Hosting** đã bật với `index.html` làm **Index document** (mục 6.3).  
     ![Nhấn Edit trong Bucket policy.](/images/6-configuring-s3-buckets/6.4-setting-bucket-policy-for-public-access/setting-bucket-policy-for-public-access-04.png)
     *Hình 4: Nhấn Edit trong Bucket policy.*

5. **Chỉnh Sửa Mã Bucket Policy**  
   - Trong giao diện **Edit bucket policy**, xóa nội dung hiện có (nếu có) và dán mã JSON sau:  
     ```json
     {
         "Version": "2012-10-17",
         "Statement": [
             {
                 "Sid": "PublicReadGetObject",
                 "Effect": "Allow",
                 "Principal": "*",
                 "Action": "s3:GetObject",
                 "Resource": "arn:aws:s3:::student-management-website-2025/*"
             }
         ]
     }
     ```  
   - **Giải thích mã JSON**:  
     - **Version**: "2012-10-17" là phiên bản định dạng chính sách IAM mới nhất.  
     - **Statement**: Danh sách các chính sách quyền.  
     - **Sid**: "PublicReadGetObject" là tên tùy chọn để nhận diện chính sách.  
     - **Effect**: "Allow" cho phép hành động được chỉ định.  
     - **Principal**: "*" cho phép mọi người (bao gồm trình duyệt và CloudFront) truy cập.  
     - **Action**: "s3:GetObject" cho phép đọc các tệp trong bucket.  
     - **Resource**: "arn:aws:s3:::student-management-website-2025/*" chỉ định tất cả các tệp trong bucket `student-management-website-2025`.  
   - Kiểm tra mã: Đảm bảo tên bucket trong **Resource** khớp với `student-management-website-2025`.  
     ![Cấu hình Bucket Policy.](/images/6-configuring-s3-buckets/6.4-setting-bucket-policy-for-public-access/setting-bucket-policy-for-public-access-05.png)
     *Hình 5: Cấu hình Bucket Policy.*

6. **Lưu Thay Đổi**  
   - Nhấn **Save changes** để áp dụng **Bucket Policy**.  
   - Kết quả mong đợi: AWS S3 hiển thị thông báo _"Successfully edited bucket policy"_.  
     ![Nhấn Save changes.](/images/6-configuring-s3-buckets/6.4-setting-bucket-policy-for-public-access/setting-bucket-policy-for-public-access-06.png)
     *Hình 6: Nhấn Save changes.*  
   - **Xử lý lỗi**:  
     - **"Policy has invalid resource"**: Kiểm tra ARN trong **Resource** đúng cú pháp (`arn:aws:s3:::student-management-website-2025/*`).  
     - **"AccessDenied"**:  
       - Kiểm tra vai trò IAM của tài khoản có quyền `s3:PutBucketPolicy`:  
         ```json
         {
             "Version": "2012-10-17",
             "Statement": [
                 {
                     "Effect": "Allow",
                     "Action": "s3:PutBucketPolicy",
                     "Resource": "arn:aws:s3:::student-management-website-2025"
                 }
             ]
         }
         ```  
       - Đảm bảo **Block all public access** đã bỏ chọn (mục 6.1).  

7. **Kiểm Tra Truy Cập Website**  
   - Trở lại tab **Properties > Static website hosting** trong bucket `student-management-website-2025`.  
   - Sao chép **Bucket website endpoint** (VD: http://student-management-website-2025.s3-website-us-east-1.amazonaws.com).  
     ![Bucket website endpoint.](/images/6-configuring-s3-buckets/6.4-setting-bucket-policy-for-public-access/setting-bucket-policy-for-public-access-07.png)
     *Hình 7: Bucket website endpoint.*  
   - Mở trình duyệt và truy cập endpoint này.  
   - Kết quả mong đợi:  
     - Giao diện web hiển thị với biểu mẫu nhập liệu, bảng sinh viên, và các nút chức năng (Lưu, Xem, Backup) sử dụng Tailwind CSS và font Poppins.  
     - Các tệp `styles.css` và `scripts.js` được tải đúng, giao diện hiển thị chính xác.  
     ![Giao diện web hiển thị qua endpoint S3.](/images/6-configuring-s3-buckets/6.4-setting-bucket-policy-for-public-access/setting-bucket-policy-for-public-access-08.png)
     *Hình 8: Giao diện web hiển thị qua endpoint S3.*  
   - **Lưu ý**:  
     - Các yêu cầu API (**GET /students**, **POST /students**, **POST /backup**) có thể gặp lỗi CORS vì endpoint S3 sử dụng HTTP và chưa tích hợp với CloudFront. Điều này sẽ được khắc phục khi cấu hình CloudFront (mục 7) và CORS trong API Gateway (mục 4.7).  
     - Endpoint S3 chỉ hỗ trợ HTTP. CloudFront sẽ cung cấp HTTPS và tăng tốc độ tải.  
   - **Xử lý lỗi**:  
     - **Lỗi 403 Forbidden**:  
       - Kiểm tra **Bucket Policy** đúng ARN (`arn:aws:s3:::student-management-website-2025/*`).  
       - Xác minh **Block all public access** đã bỏ chọn (mục 6.1).  
       - Đảm bảo các tệp `index.html`, `styles.css`, `scripts.js` được tải lên với quyền `public-read` (mục 6.2) hoặc được bao phủ bởi **Bucket Policy**.  
     - **Lỗi 404 Not Found**:  
       - Xác minh `index.html` đã được tải lên thư mục gốc (mục 6.2).  
       - Kiểm tra **Static Website Hosting** đã bật với `index.html` là **Index document** (mục 6.3).  
     - **Giao diện hiển thị sai**:  
       - Mở **Developer Tools > Console** trong trình duyệt để kiểm tra lỗi (VD: tệp CSS/JS không tải).  
       - Xác minh đường dẫn trong `index.html` (VD: `<link href="styles.css">`, `<script src="scripts.js">`).  

---

## Lưu Ý Quan Trọng

| Yếu Tố | Chi Tiết |
|--------|----------|
| Bảo mật | Quyền công khai (`Principal: "*"`) phù hợp cho kiểm tra ban đầu, nhưng không an toàn cho môi trường sản xuất. Sử dụng CloudFront **Origin Access Identity (OAI)**: <br> - Tạo OAI trong CloudFront > Origin access identities, gắn vào phân phối CloudFront (mục 7). <br> - Bật lại **Block public access** (trừ **Block public access for bucket policies**) sau khi cấu hình OAI. <br> - Tránh nhúng `StudentApiKey` trong `scripts.js`. Sử dụng AWS Secrets Manager hoặc CloudFront Functions: <br> function handler(event) { var request = event.request; request.headers['x-api-key'] = { value: 'xxxxxxxxxxxxxxxxxxxx' }; return request; } |
| Tối ưu hóa | Bật **S3 Access Logs**: Trong S3 > student-management-website-2025 > Properties > Server access logging, chọn **Enable**, chỉ định bucket log (VD: student-web-logs-20250706). Sử dụng AWS CLI: <br> aws s3api put-bucket-policy --bucket student-management-website-2025 --policy file://policy.json |
| Tích hợp với hệ thống | Tích hợp với CloudFront (mục 7): <br> - Sử dụng **Bucket website endpoint** làm Origin. <br> - Đặt **Default root object**: `index.html`. <br> - Cấu hình **Viewer protocol policy**: Redirect HTTP to HTTPS. <br> Cập nhật CORS trong API Gateway (mục 4.7) với `Access-Control-Allow-Origin: https://d12345678.cloudfront.net`. |
| Kiểm tra tích hợp | Truy cập **Bucket website endpoint** để kiểm tra giao diện. Sau khi cấu hình CloudFront, truy cập CloudFront URL (https://d12345678.cloudfront.net) và kiểm tra: <br> - **POST /students**: Lưu bản ghi vào DynamoDB `studentData`, gửi email SES. <br> - **GET /students**: Hiển thị bảng. <br> - **POST /backup**: Tạo tệp trong `student-backup-20250706`, gửi email. <br> Sử dụng **Developer Tools > Network** để kiểm tra yêu cầu API. |
| Xử lý lỗi | **403 Forbidden**: Kiểm tra **Bucket Policy** ARN, **Block all public access** (mục 6.1), quyền `public-read` của tệp (mục 6.2). **404 Not Found**: Xác minh `index.html` ở thư mục gốc, **Static Website Hosting** bật đúng (mục 6.3). **Giao diện sai**: Kiểm tra **Developer Tools > Console**, đường dẫn trong `index.html`. **CORS**: Kiểm tra header `Access-Control-Allow-Origin` trong Lambda (mục 3.1, 3.2, 3.3) và API Gateway (mục 4.7). **429**: Kiểm tra giới hạn Rate/Burst/Quota trong `StudentUsagePlan` (mục 4.3). |

> **Mẹo thực tiễn**: Kiểm tra **Bucket website endpoint** ngay sau khi lưu **Bucket Policy**. Sử dụng AWS CLI để tự động hóa nếu cần áp dụng chính sách cho nhiều bucket. Chuẩn bị cho mục 7 (cấu hình CloudFront) để tăng bảo mật và hỗ trợ HTTPS.

---

## Kết Luận

**Bucket Policy** đã được cấu hình trên bucket `student-management-website-2025`, cho phép truy cập công khai (`s3:GetObject`) để phục vụ giao diện web. Bucket sẵn sàng tích hợp với CloudFront (mục 7) để hỗ trợ HTTPS và hiệu suất cao.

> **Bước tiếp theo**: Chuyển đến [Cấu hình CloudFront để phân phối nội dung](/7-configuring-cloudfront/) để tiếp tục cấu hình!