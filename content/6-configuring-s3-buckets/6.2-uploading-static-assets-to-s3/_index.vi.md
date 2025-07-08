---
title: "Tải Tài Nguyên Giao Diện Lên S3 (HTML/CSS/JS)"
date: 2023-10-25
weight: 2
chapter: false
pre: "<b>6.2 </b>"
---

> **Mục tiêu**: Tải các tệp giao diện web tĩnh (`index.html`, `styles.css`, `scripts.js` từ mục 5) lên S3 Bucket `student-management-website-2025` (tạo ở mục 6.1) để chuẩn bị cho việc bật **Static Website Hosting** (mục 6.3) và phục vụ qua CloudFront (mục 7). Các tệp này tạo nên giao diện của ứng dụng Quản Lý Dữ Liệu Sinh Viên, cho phép người dùng nhập, xem, và sao lưu dữ liệu sinh viên thông qua các endpoint API **GET /students**, **POST /students**, và **POST /backup** (mục 4.8) với bảo mật API Key (`StudentApiKey`, mục 4.2) và CORS (mục 4.7).

---

## Tổng Quan về Tài Nguyên Giao Diện

- **Các tệp cần tải lên**:  
  - `index.html`: Cấu trúc giao diện với biểu mẫu nhập liệu, bảng hiển thị sinh viên, và các nút chức năng (Lưu, Xem, Backup).  
  - `styles.css`: Tùy chỉnh giao diện với Tailwind CSS, font Poppins, gradient màu sắc, và hiệu ứng động.  
  - `scripts.js`: Logic gọi API sử dụng jQuery, xử lý yêu cầu tới **Invoke URL** (VD: `https://abc123.execute-api.us-east-1.amazonaws.com/prod`) với header `x-api-key: <StudentApiKey>`.  
- **Vai trò của bucket `student-management-website-2025`**:  
  - Lưu trữ các tệp tĩnh để phục vụ giao diện web qua **Static Website Hosting**.  
  - Được cấu hình quyền công khai (`s3:GetObject`) trong **Bucket Policy** (mục 6.4) để CloudFront truy xuất nội dung.  
  - Tích hợp với CloudFront để cung cấp HTTPS, tăng tốc độ tải, và bảo mật tốt hơn.  
- **Tích hợp với hệ thống**:  
  - Giao diện web gọi API `student` (stage `prod`, mục 4.8) để thực hiện các chức năng:  
    - **POST /students**: Lưu bản ghi vào DynamoDB `studentData` và gửi email xác nhận qua SES.  
    - **GET /students**: Hiển thị dữ liệu trong bảng.  
    - **POST /backup**: Tạo tệp backup trong S3 Bucket `student-backup-20250706` (mục 2.4, 6.5) và gửi email thông báo qua SES.  
  - CORS được cấu hình (mục 4.7) để hỗ trợ yêu cầu từ domain CloudFront (VD: `https://d12345678.cloudfront.net`).

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành mục 6.1 (tạo bucket `student-management-website-2025`), mục 5 (xây dựng giao diện web với `index.html`, `styles.css`, `scripts.js`), mục 4.1 (tạo API `student`), mục 4.2 (tạo API Key `StudentApiKey`), mục 4.3 (tạo Usage Plan `StudentUsagePlan`), mục 4.4 (tạo phương thức **GET /students**), mục 4.5 (tạo phương thức **POST /students**), mục 4.6 (tạo resource `/backup` và phương thức **POST /backup**), mục 4.7 (kích hoạt CORS), mục 4.8 (triển khai API lên stage `prod`), mục 4.9 (gắn `StudentApiKey` vào `StudentUsagePlan` và liên kết với API `student` stage `prod`), mục 3 (tạo các hàm Lambda `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, bảng DynamoDB `studentData`, bucket `student-backup-20250706`, SES email xác minh). Đảm bảo tài khoản AWS có quyền truy cập S3 (`s3:PutObject`) và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console**  
   - Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS của bạn.  
   - Trong thanh tìm kiếm ở đầu trang, nhập **S3** và chọn dịch vụ **Amazon S3** để vào giao diện quản lý bucket.  
   - Kiểm tra vùng AWS: Đảm bảo bạn đang làm việc trong vùng **us-east-1** (US East (N. Virginia)) để đồng bộ với bucket `student-management-website-2025`, API `student`, các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`), bảng DynamoDB `studentData`, bucket `student-backup-20250706`, và SES. Vùng được hiển thị ở góc trên bên phải AWS Console.  
     ![Giao diện AWS Console với thanh tìm kiếm S3.](/images/6-configuring-s3-buckets/6.2-uploading-static-assets-to-s3/uploading-static-assets-to-s3-01.png)
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm S3.*

2. **Chọn Bucket `student-management-website-2025`**  
   - Trong giao diện chính của **Amazon S3 > Buckets**, tìm và chọn bucket `student-management-website-2025` (tạo ở mục 6.1).  
   - Nếu không thấy bucket:  
     - Kiểm tra vùng AWS (`us-east-1`) và làm mới trang.  
     - Xác minh bucket đã được tạo thành công với tên chính xác (tên bucket là duy nhất toàn cầu, có thể bạn đã dùng tên khác như `student-management-website-20250706-abc123`).  
   - Nhấn vào tên bucket để vào giao diện quản lý **Objects** của `student-management-website-2025`.  
     ![Chọn bucket student-management-website-2025.](/images/6-configuring-s3-buckets/6.2-uploading-static-assets-to-s3/uploading-static-assets-to-s3-02.png)
     *Hình 2: Chọn bucket `student-management-website-2025`.*

3. **Mở Giao Diện Upload**  
   - Trong giao diện **Objects** của bucket `student-management-website-2025`, nhấn nút **Upload** (thường nằm ở góc trên bên phải).  
   - Giao diện **Upload** sẽ mở ra, cho phép bạn chọn hoặc kéo thả các tệp để tải lên.  
     ![Nút Upload trong giao diện bucket.](/images/6-configuring-s3-buckets/6.2-uploading-static-assets-to-s3/uploading-static-assets-to-s3-03.png)
     *Hình 3: Nút Upload trong giao diện bucket.*

4. **Chuẩn Bị và Kéo Thả Tệp để Tải Lên**  
   - **Chuẩn bị tệp**:  
     - Đảm bảo bạn có các tệp từ mục 5:  
       - `index.html`: Giao diện với biểu mẫu, bảng, và nút chức năng, sử dụng Tailwind CSS và jQuery.  
       - `styles.css`: Style tùy chỉnh với font Poppins, gradient, và hiệu ứng responsive.  
       - `scripts.js`: Logic gọi API với **Invoke URL** (VD: `https://abc123.execute-api.us-east-1.amazonaws.com/prod`) và `StudentApiKey` (VD: `xxxxxxxxxxxxxxxxxxxx`).  
     - Lưu các tệp trong một thư mục cục bộ (VD: `student-web-files/`) để dễ quản lý.  
     - Kiểm tra nội dung:  
       - Mở `scripts.js`, xác minh `API_ENDPOINT` và `API_KEY` đã được thay bằng **Invoke URL** (mục 4.8) và `StudentApiKey` (mục 4.2).  
       - Nếu chưa thay, cập nhật:  
         ```javascript
         const API_ENDPOINT = 'https://abc123.execute-api.us-east-1.amazonaws.com/prod';
         const API_KEY = 'xxxxxxxxxxxxxxxxxxxx';
         ```  
       - **Lưu ý bảo mật**: Không nhúng `API_KEY` trực tiếp; xem đề xuất trong **Lưu ý** để sử dụng AWS Secrets Manager hoặc CloudFront Functions.  
     - Mở `index.html` cục bộ trong trình duyệt để đảm bảo giao diện hiển thị đúng trước khi tải lên.  
   - **Kéo thả tệp**:  
     - Trong giao diện **Upload**, kéo thả các tệp `index.html`, `styles.css`, `scripts.js` từ thư mục cục bộ vào khu vực tải lên.  
     - Hoặc nhấn **Add files** và chọn từng tệp từ máy tính.  
     - **Cấu trúc tệp**:  
       - Tải các tệp trực tiếp vào **thư mục gốc** của bucket (không tạo thư mục con như `css/`, `js/`) để đảm bảo đường dẫn đơn giản (VD: `https://student-management-website-2025.s3-website-us-east-1.amazonaws.com/index.html`).  
       - Nếu cần thư mục con, tạo trước trong bucket (VD: **Create folder** > `css`, `js`) và tải tệp tương ứng, nhưng phải cập nhật đường dẫn trong `index.html`:  
         ```html
         <link rel="stylesheet" href="/css/styles.css">
         <script src="/js/scripts.js"></script>
         ```  

5. **Tải Tệp Lên Bucket**  
   - Sau khi chọn các tệp, kiểm tra danh sách trong giao diện **Upload** hiển thị `index.html`, `styles.css`, `scripts.js`.  
     ![Danh sách tệp trong giao diện Upload.](/images/6-configuring-s3-buckets/6.2-uploading-static-assets-to-s3/uploading-static-assets-to-s3-04.png)
     *Hình 4: Danh sách tệp trong giao diện Upload.*  
   - Trong mục **Permissions** (trong giao diện Upload):  
     - **Predefined ACLs**: Chọn **Grant public-read access** để đảm bảo CloudFront có thể truy xuất tệp.  
     - **Lưu ý**: Quyền này sẽ được thay thế bằng **Bucket Policy** (mục 6.4) để quản lý tập trung, nhưng chọn ở đây để đơn giản hóa kiểm tra ban đầu.  
   - Trong mục **Properties** (tùy chọn):  
     - **Storage class**: Chọn **Standard** (mặc định) để đảm bảo hiệu suất tốt cho giao diện web.  
     - **Server-side encryption**: Đảm bảo **Enable** với **SSE-S3** (đã cấu hình ở mục 6.1).  
   - Nhấn **Upload** để bắt đầu tải tệp.  
     ![Nhấn Upload để tải tệp.](/images/6-configuring-s3-buckets/6.2-uploading-static-assets-to-s3/uploading-static-assets-to-s3-05.png)
     *Hình 5: Nhấn Upload để tải tệp.*

6. **Kiểm Tra Trạng Thái Tải Lên**  
   - Sau khi nhấn **Upload**, AWS S3 sẽ xử lý và hiển thị thông báo: _"Upload succeeded"_ khi tất cả tệp được tải lên thành công.  
     ![Thông báo Upload succeeded.](/images/6-configuring-s3-buckets/6.2-uploading-static-assets-to-s3/uploading-static-assets-to-s3-06.png)
     *Hình 6: Thông báo Upload succeeded.*  
   - Để xác minh:  
     - Trong **S3 > Buckets > student-management-website-2025 > Objects**, kiểm tra danh sách hiển thị `index.html`, `styles.css`, `scripts.js`.  
     - Nhấn vào từng tệp để xem chi tiết (VD: URL, kích thước, ngày tải lên).  
   - **Xử lý lỗi**:  
     - Nếu gặp lỗi _"AccessDenied"_:  
       - Đảm bảo **Block all public access** đã bỏ chọn trong mục 6.1.  
       - Kiểm tra vai trò IAM của tài khoản AWS có quyền `s3:PutObject`.  
     - Nếu tệp không hiển thị:  
       - Làm mới trang hoặc kiểm tra vùng AWS (`us-east-1`).  
       - Xác minh bạn đã chọn đúng bucket `student-management-website-2025`.  
     - Nếu thông báo _"Upload failed"_:  
       - Kiểm tra kết nối mạng hoặc kích thước tệp (S3 hỗ trợ tối đa 5TB/tệp).  
       - Thử tải lại từng tệp riêng lẻ để xác định tệp có vấn đề.

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Cấu trúc tệp** | - Tải các tệp vào **thư mục gốc** để giữ đường dẫn đơn giản (VD: `/index.html`, `/styles.css`, `/scripts.js`). <br> - Nếu dùng thư mục con (`css/`, `js/`), cập nhật đường dẫn trong `index.html` và kiểm tra khi bật **Static Website Hosting** (mục 6.3). |
| **Bảo mật** | - Tránh nhúng `StudentApiKey` trực tiếp trong `scripts.js`. Sử dụng AWS Secrets Manager hoặc CloudFront Functions để thêm header `x-api-key`: <br> ```javascript <br> // Ví dụ với CloudFront Functions <br> function handler(event) { <br>   var request = event.request; <br>   request.headers['x-api-key'] = { value: 'xxxxxxxxxxxxxxxxxxxx' }; <br>   return request; <br> } <br> - Sau khi tải lên, cấu hình **Bucket Policy** (mục 6.4) để quản lý quyền `s3:GetObject` thay vì dựa vào ACL `public-read`. <br> - Sử dụng CloudFront **Origin Access Identity (OAI)** (mục 7) để tăng bảo mật, hạn chế truy cập trực tiếp vào S3. |
| **Tối ưu hóa** | - **Nén tệp**: Nén `styles.css` và `scripts.js` (sử dụng UglifyJS hoặc CSSNano) để giảm thời gian tải. <br> - **Kiểm tra nội dung**: Mở `index.html` cục bộ trong trình duyệt để đảm bảo giao diện hiển thị đúng trước khi tải lên. <br> - **Sử dụng AWS CLI**: Tải tệp nhanh hơn với lệnh: <br> ```bash <br> aws s3 cp student-web-files/ s3://student-management-website-2025/ --recursive <br> ``` <br> - **S3 Versioning**: Đã bật ở mục 6.1, đảm bảo khôi phục được nếu tải nhầm tệp. |
| **Tích hợp với hệ thống** | - Sau khi tải tệp, bật **Static Website Hosting** (mục 6.3) để lấy endpoint (VD: `http://student-management-website-2025.s3-website-us-east-1.amazonaws.com`). <br> - Cấu hình **Bucket Policy** (mục 6.4) để cho phép CloudFront truy xuất. <br> - Tích hợp với CloudFront (mục 7) để phục vụ giao diện qua HTTPS và tăng tốc độ tải. <br> - Đảm bảo CORS trong API Gateway (mục 4.7) hỗ trợ yêu cầu từ CloudFront domain (VD: `https://d12345678.cloudfront.net`). |
| **Kiểm tra tích hợp** | - Kiểm tra các tệp trong **S3 > Buckets > student-management-website-2025 > Objects**. <br> - Sau khi bật **Static Website Hosting** (mục 6.3), truy cập endpoint S3 (VD: `http://student-management-website-2025.s3-website-us-east-1.amazonaws.com`) để kiểm tra giao diện. <br> - **Kết quả mong đợi**: Giao diện hiển thị với biểu mẫu, bảng, và nút chức năng. <br> - **Lưu ý**: Các yêu cầu API có thể gặp lỗi CORS nếu chưa cấu hình CloudFront; sẽ khắc phục trong mục 7. <br> - Sau khi tích hợp CloudFront, kiểm tra chức năng: <br> - **POST /students**: Lưu bản ghi vào DynamoDB `studentData` và gửi email qua SES. <br> - **GET /students**: Hiển thị dữ liệu trong bảng. <br> - **POST /backup**: Tạo tệp trong `student-backup-20250706` và gửi email thông báo. |
| **Xử lý lỗi** | - **403 Forbidden**: Kiểm tra quyền `s3:PutObject` và **Bucket Policy** (mục 6.4). <br> - **Tệp không hiển thị**: Xác minh tệp được tải vào đúng bucket và thư mục gốc. <br> - **Giao diện lỗi**: Kiểm tra đường dẫn trong `index.html` (VD: `<link href="styles.css">`, `<script src="scripts.js">`) và log trình duyệt (**Developer Tools > Console**). |

> **Mẹo thực tiễn**: Trước khi tải lên, kiểm tra giao diện cục bộ bằng `npx serve` hoặc server tĩnh để đảm bảo các tệp hoạt động đúng. Sử dụng AWS CLI để tải nhanh hơn nếu có nhiều tệp. Sau khi tải, kiểm tra danh sách tệp trong bucket và chuẩn bị cho mục 6.3 (bật **Static Website Hosting**).

---

## Kết Luận

Các tệp `index.html`, `styles.css`, `scripts.js` đã được tải lên bucket `student-management-website-2025`, sẵn sàng để bật **Static Website Hosting** (mục 6.3) và tích hợp với CloudFront (mục 7) để phục vụ giao diện web.

> **Bước tiếp theo**: Chuyển đến [Bật tính năng Static Website Hosting](/6-configuring-s3-buckets/6.3-enabling-static-website-hosting/) để tiếp tục cấu hình!