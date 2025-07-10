---
title: "Cấu Hình Default Root Object"
date: 2025-07-09
weight: 2
chapter: false
pre: "<b>7.2. </b>"
---

> **Mục tiêu**: Cấu hình `index.html` làm **Default Root Object** cho CloudFront Distribution `StudentWebsiteDistribution` (mục 7.1) để CloudFront tự động phục vụ tệp `index.html` từ S3 Bucket `student-management-website-2025` khi người dùng truy cập domain CloudFront (VD: https://d12345678.cloudfront.net). Điều này đảm bảo giao diện web tĩnh (biểu mẫu, bảng sinh viên, nút chức năng) hiển thị đúng và tích hợp với API `student` (stage `prod`, mục 4.8) để thực hiện các chức năng như lưu, xem, và sao lưu dữ liệu.

---

## Tổng Quan về Default Root Object

- **Vai trò của Default Root Object**:  
  - Chỉ định tệp mặc định (`index.html`) mà CloudFront trả về khi người dùng truy cập URL gốc của distribution (VD: https://d12345678.cloudfront.net).  
  - Tương tự **Index document** trong S3 **Static Website Hosting** (mục 6.3), nhưng áp dụng ở tầng CloudFront.  
  - Đảm bảo giao diện chính hiển thị mà không cần nhập đường dẫn cụ thể (VD: /index.html).  
- **Tích hợp với hệ thống**:  
  - CloudFront phân phối các tệp tĩnh (`index.html`, `styles.css`, `scripts.js`, mục 6.2) từ S3 Bucket `student-management-website-2025` (mục 6.1–6.4) thông qua **Origin Access Identity (OAI)** (mục 7.1) để giới hạn truy cập.  
  - Giao diện web gọi API `student` (mục 4.8) với **Invoke URL** (VD: https://abc123.execute-api.us-east-1.amazonaws.com/prod) và `StudentApiKey` (mục 4.2).  
  - Các chức năng:  
    - **POST /students**: Lưu bản ghi vào DynamoDB `studentData` và gửi email qua SES.  
    - **GET /students**: Hiển thị dữ liệu trong bảng.  
    - **POST /backup**: Tạo tệp trong S3 Bucket `student-backup-20250706` (mục 6.5) và gửi email thông báo.  
  - CORS được cấu hình (mục 4.7) để hỗ trợ yêu cầu từ domain CloudFront (VD: https://d12345678.cloudfront.net).

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành mục 7.1 (tạo CloudFront Distribution `StudentWebsiteDistribution`), mục 6.1 (tạo bucket `student-management-website-2025`), mục 6.2 (tải lên `index.html`, `styles.css`, `scripts.js`), mục 6.3 (bật **Static Website Hosting**), mục 6.4 (cấu hình **Bucket Policy**), mục 6.5 (cấu hình bucket `student-backup-20250706`), mục 5 (xây dựng giao diện web), mục 4.1 (tạo API `student`), mục 4.2 (tạo API Key `StudentApiKey`), mục 4.3 (tạo Usage Plan `StudentUsagePlan`), mục 4.4 (tạo phương thức **GET /students**), mục 4.5 (tạo phương thức **POST /students**), mục 4.6 (tạo resource `/backup` và phương thức **POST /backup**), mục 4.7 (kích hoạt CORS), mục 4.8 (triển khai API lên stage `prod`), mục 4.9 (gắn `StudentApiKey` vào `StudentUsagePlan`). Đảm bảo tài khoản AWS có quyền `cloudfront:UpdateDistribution`, `s3:GetObject`, và vùng AWS là `us-east-1` cho các dịch vụ liên quan.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console**  
   - Đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS.  
   - Trong thanh tìm kiếm, nhập **CloudFront** và chọn dịch vụ **Amazon CloudFront**.  
   - Kiểm tra vùng AWS: CloudFront là dịch vụ toàn cầu, nhưng đảm bảo S3 Bucket `student-management-website-2025`, API `student`, Lambda, DynamoDB, và SES ở `us-east-1`.  
     ![Giao diện AWS Console với thanh tìm kiếm CloudFront.](/images/7-deploying-cloudfront/7.2-configuring-default-root-object/configuring-default-root-object-01.png)
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm CloudFront.*

2. **Chọn CloudFront Distribution**  
   - Trong **CloudFront > Distributions**, tìm và chọn distribution có tên `StudentWebsiteDistribution` (tạo ở mục 7.1).  
     - **Nhận diện**: Distribution có ID bắt đầu bằng `E...` và Domain name dạng `d12345678.cloudfront.net`.  
   - Nhấn vào ID hoặc tên distribution để vào giao diện chi tiết.  
   - Kiểm tra trạng thái: Đảm bảo distribution ở trạng thái **Enabled**. Nếu vẫn là **In Progress**, chờ 5–15 phút để triển khai hoàn tất.  
     ![Chọn CloudFront Distribution.](/images/7-deploying-cloudfront/7.2-configuring-default-root-object/configuring-default-root-object-02.png)
     *Hình 2: Chọn CloudFront Distribution.*

3. **Chỉnh Sửa Default Root Object**  
   - Trong giao diện chi tiết của `StudentWebsiteDistribution`, chọn tab **General**.  
   - Tìm phần **Settings** và nhấn nút **Edit** bên cạnh **Default root object** (thường hiển thị giá trị hiện tại, nếu có).  
     ![Tìm và nhấn Edit trong phần Settings.](/images/7-deploying-cloudfront/7.2-configuring-default-root-object/configuring-default-root-object-03.png)
     *Hình 3: Tìm và nhấn Edit trong phần Settings.*  
   - Trong trường **Default root object**, nhập `index.html`.  
     - **Lý do**: `index.html` là tệp chính chứa giao diện web (biểu mẫu nhập liệu, bảng sinh viên, nút chức năng Lưu/Xem/Backup) được tải lên S3 Bucket `student-management-website-2025` (mục 6.2). Khi người dùng truy cập domain CloudFront, CloudFront sẽ yêu cầu `index.html` từ S3 qua OAI (mục 7.1).  
   - Kiểm tra trước khi lưu:  
     - Đảm bảo `index.html` đã được tải lên thư mục gốc của S3 Bucket `student-management-website-2025` (mục 6.2).  
     - Xác minh **Static Website Hosting** đã bật với `index.html` làm **Index document** (mục 6.3).  
     - Kiểm tra **Bucket Policy** (mục 7.1) cho phép OAI truy cập:  
       ```json
       {
           "Version": "2012-10-17",
           "Statement": [
               {
                   "Sid": "AllowCloudFrontOAI",
                   "Effect": "Allow",
                   "Principal": {
                       "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity EXXXXXX"
                   },
                   "Action": "s3:GetObject",
                   "Resource": "arn:aws:s3:::student-management-website-2025/*"
               }
           ]
       }
       ```

4. **Lưu Thay Đổi**  
   - Nhấn **Save changes** để áp dụng cấu hình.  
     ![Nhấn Save changes để lưu cấu hình.](/images/7-deploying-cloudfront/7.2-configuring-default-root-object/configuring-default-root-object-04.png)
     *Hình 4: Nhấn Save changes để lưu cấu hình.*  
   - Kết quả mong đợi: CloudFront bắt đầu cập nhật cấu hình (mất 5–10 phút). Sau khi hoàn tất, trạng thái distribution trở lại **Enabled**, và AWS hiển thị thông báo _"Successfully updated distribution settings"_.  
     ![Thông báo cập nhật thành công.](/images/7-deploying-cloudfront/7.2-configuring-default-root-object/configuring-default-root-object-05.png)
     *Hình 5: Thông báo cập nhật thành công.*  
   - **Xử lý lỗi**:  
     - **"AccessDenied"**: Kiểm tra vai trò IAM có quyền `cloudfront:UpdateDistribution`:  
       ```json
       {
           "Version": "2012-10-17",
           "Statement": [
               {
                   "Effect": "Allow",
                   "Action": "cloudfront:UpdateDistribution",
                   "Resource": "arn:aws:cloudfront::<AWS_ACCOUNT_ID>:distribution/<DISTRIBUTION_ID>"
               }
           ]
       }
       ```  
       - Thay `<AWS_ACCOUNT_ID>` và `<DISTRIBUTION_ID>` bằng giá trị thực (tìm trong CloudFront > Distributions).  
     - **Cập nhật không áp dụng**:  
       - Kiểm tra trạng thái distribution, chờ cho đến khi trở lại **Enabled**.  
       - Xác minh trường **Default root object** hiển thị `index.html` trong tab **General**.

5. **Kiểm Tra Default Root Object**  
   - Trong **CloudFront > Distributions**, sao chép **Distribution domain name** (VD: `https://d12345678.cloudfront.net`).  
   - Mở trình duyệt và truy cập URL này.  
   - Kết quả mong đợi:  
     - Giao diện web hiển thị với biểu mẫu nhập liệu, bảng sinh viên, và các nút chức năng (Lưu, Xem, Backup) sử dụng Tailwind CSS và font Poppins.  
     - Các tệp `styles.css` và `scripts.js` được tải đúng qua HTTPS, giao diện hiển thị chính xác.  
     - Yêu cầu API (**GET /students**, **POST /students**, **POST /backup**) hoạt động nếu CORS được cấu hình đúng (mục 4.7).  
     ![Giao diện web qua CloudFront.](/images/7-deploying-cloudfront/7.2-configuring-default-root-object/configuring-default-root-object-06.png)
     *Hình 6: Giao diện web qua CloudFront.*  
   - **Xử lý lỗi**:  
     - **Lỗi 403 Forbidden**:  
       - Kiểm tra **Bucket Policy** của `student-management-website-2025` (mục 7.1) cho phép OAI truy cập với đúng `<OAI_ID>`.  
       - Xác minh `index.html` được tải lên thư mục gốc của S3 (mục 6.2).  
       - Đảm bảo **Block public access** được bật (trừ **Block public access for bucket policies**) trong S3 (mục 7.1).  
     - **Lỗi 404 Not Found**:  
       - Kiểm tra **Default root object** được đặt là `index.html` trong CloudFront > Distributions > General.  
       - Xác minh **Static Website Hosting** bật với `index.html` làm **Index document** (mục 6.3).  
     - **Giao diện hiển thị sai**:  
       - Mở **Developer Tools > Console** trong trình duyệt để kiểm tra lỗi tải `styles.css` hoặc `scripts.js`.  
       - Kiểm tra đường dẫn trong `index.html` (VD: `<link href="styles.css">`, `<script src="scripts.js">`) khớp với cấu trúc thư mục trong S3.  
     - **Lỗi CORS khi gọi API**:  
       - Kiểm tra cấu hình CORS trong API Gateway (mục 4.7) có `Access-Control-Allow-Origin: https://d12345678.cloudfront.net`.  
       - Đảm bảo `scripts.js` gửi yêu cầu API với đúng **Invoke URL** (VD: https://abc123.execute-api.us-east-1.amazonaws.com/prod) và header `x-api-key: <StudentApiKey>`.

---

## Lưu Ý Quan Trọng

| Yếu Tố | Chi Tiết |
|--------|----------|
| Bảo mật | Đảm bảo **Bucket Policy** chỉ cho phép OAI truy cập S3 (mục 7.1). Tránh nhúng `StudentApiKey` trong `scripts.js`. Sử dụng CloudFront Functions để thêm header `x-api-key`: <br> ```javascript <br> function handler(event) { <br>     var request = event.request; <br>     request.headers['x-api-key'] = { value: 'xxxxxxxxxxxxxxxxxxxx' }; <br>     return request; <br> } <br> ``` |
| Tối ưu hóa | Bật **CloudFront Standard Logs** để theo dõi truy cập: Trong **CloudFront > Distribution > General > Logging**, chọn **On**, chỉ định bucket log (VD: `student-web-logs-20250706`). Sử dụng AWS CLI để kiểm tra cấu hình: <br> ```bash <br> aws cloudfront get-distribution --id <DISTRIBUTION_ID> <br> ``` |
| Tích hợp với hệ thống | Cập nhật CORS trong API Gateway (mục 4.7) với `Access-Control-Allow-Origin: https://d12345678.cloudfront.net`. Đảm bảo endpoint **POST /students**, **GET /students**, **POST /backup** hoạt động với **Invoke URL** và `StudentApiKey`. |
| Kiểm tra tích hợp | Truy cập CloudFront URL (https://d12345678.cloudfront.net) và kiểm tra: <br> - **POST /students**: Lưu bản ghi, gửi email SES. <br> - **GET /students**: Hiển thị bảng. <br> - **POST /backup**: Tạo tệp trong `student-backup-20250706`, gửi email. <br> Sử dụng **Developer Tools > Network** để kiểm tra yêu cầu API. |
| Xử lý lỗi | **403 Forbidden**: Kiểm tra OAI ARN, **Bucket Policy**, quyền `s3:GetObject`. **404 Not Found**: Xác minh `index.html` là **Default root object**, tệp tồn tại trong S3. **CORS**: Kiểm tra header `Access-Control-Allow-Origin` trong Lambda (mục 3) và API Gateway (mục 4.7). **429**: Kiểm tra giới hạn Rate/Burst/Quota trong `StudentUsagePlan` (mục 4.3). |

> **Mẹo thực tiễn**: Kiểm tra CloudFront URL ngay sau khi cập nhật **Default root object**. Nếu giao diện chưa hiển thị đúng, tạo invalidation (mục 7.3) để làm mới cache. Sử dụng AWS CLI để kiểm tra cấu hình: `aws cloudfront get-distribution --id <DISTRIBUTION_ID>`.

---

## Kết Luận

**Default Root Object** đã được cấu hình là `index.html` cho CloudFront Distribution `StudentWebsiteDistribution`, đảm bảo giao diện web hiển thị đúng khi truy cập domain CloudFront. Hệ thống sẵn sàng tích hợp với API `student`.

> **Bước tiếp theo**: Chuyển đến [Tạo Invalidation để làm mới nội dung cache](/7-deploying-cloudfront/7.3-creating-cloudfront-invalidation/) để tiếp tục!