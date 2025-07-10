---
title: "Tạo CloudFront Distribution"
date: 2025-07-09
weight: 1
chapter: false
pre: "<b>7.1. </b>"
---

> **Mục tiêu**: Tạo một CloudFront Distribution để phân phối nội dung tĩnh từ S3 Bucket `student-management-website-2025` (mục 6.1–6.4), sử dụng **Origin Access Identity (OAI)** để giới hạn truy cập bucket chỉ từ CloudFront, bật **Web Application Firewall (WAF)** để tăng bảo mật, và cung cấp HTTPS cho giao diện web (`index.html`, `styles.css`, `scripts.js`). Distribution sẽ tích hợp với API `student` (stage `prod`, mục 4.8) để hỗ trợ các endpoint **GET /students**, **POST /students**, và **POST /backup**, sử dụng `StudentApiKey` (mục 4.2) với CORS (mục 4.7).

---

## Tổng Quan về CloudFront Distribution

- **Vai trò của CloudFront**:  
  - Cung cấp HTTPS cho giao diện web (S3 **Static Website Hosting** chỉ hỗ trợ HTTP, mục 6.3).  
  - Tăng tốc độ tải bằng cách lưu cache tại các edge locations toàn cầu.  
  - Sử dụng OAI để bảo mật, thay thế chính sách công khai (`Principal: "*"` , mục 6.4).  
  - Bật WAF để bảo vệ chống tấn công (VD: SQL injection, DDoS).  
- **Tích hợp với hệ thống**:  
  - Phục vụ các tệp tĩnh (`index.html`, `styles.css`, `scripts.js`, mục 6.2) từ S3 Bucket `student-management-website-2025`.  
  - Giao diện web gọi API `student` (mục 4.8) với **Invoke URL** (VD: https://abc123.execute-api.us-east-1.amazonaws.com/prod) và `StudentApiKey`.  
  - Các chức năng:  
    - **POST /students**: Lưu bản ghi vào DynamoDB `studentData` và gửi email qua SES.  
    - **GET /students**: Hiển thị dữ liệu trong bảng.  
    - **POST /backup**: Tạo tệp trong S3 Bucket `student-backup-20250706` (mục 6.5) và gửi email thông báo.  
  - CORS được cấu hình (mục 4.7) để hỗ trợ yêu cầu từ domain CloudFront (VD: https://d12345678.cloudfront.net).

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành mục 6.1 (tạo bucket `student-management-website-2025`), mục 6.2 (tải lên `index.html`, `styles.css`, `scripts.js`), mục 6.3 (bật **Static Website Hosting**), mục 6.4 (cấu hình **Bucket Policy**), mục 6.5 (cấu hình bucket `student-backup-20250706`), mục 5 (xây dựng giao diện web), mục 4.1 (tạo API `student`), mục 4.2 (tạo API Key `StudentApiKey`), mục 4.3 (tạo Usage Plan `StudentUsagePlan`), mục 4.4 (tạo phương thức **GET /students**), mục 4.5 (tạo phương thức **POST /students**), mục 4.6 (tạo resource `/backup` và phương thức **POST /backup**), mục 4.7 (kích hoạt CORS), mục 4.8 (triển khai API lên stage `prod`), mục 4.9 (gắn `StudentApiKey` vào `StudentUsagePlan`). Đảm bảo tài khoản AWS có quyền `cloudfront:CreateDistribution`, `cloudfront:CreateInvalidation`, `s3:PutBucketPolicy`, và vùng AWS là `us-east-1` cho các dịch vụ liên quan.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console**  
   - Đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS.  
   - Trong thanh tìm kiếm, nhập **CloudFront** và chọn dịch vụ **Amazon CloudFront**.  
   - Kiểm tra vùng AWS: CloudFront là dịch vụ toàn cầu, nhưng đảm bảo S3 Bucket `student-management-website-2025`, API `student`, Lambda, DynamoDB, và SES ở `us-east-1`.  
     ![Giao diện AWS Console với thanh tìm kiếm CloudFront.](/images/7-deploying-cloudfront/7.1-creating-a-cloudfront-distribution/creating-a-cloudfront-distribution-01.png)  
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm CloudFront.*

2. **Mở Giao Diện Tạo Distribution**  
   - Trong **CloudFront > Distributions**, nhấn **Create distribution**.  
     ![Nút Create distribution trong CloudFront.](/images/7-deploying-cloudfront/7.1-creating-a-cloudfront-distribution/creating-a-cloudfront-distribution-02.png)  
     *Hình 2: Nút Create distribution trong CloudFront.*

3. **Cấu Hình Distribution Name và Origin**  
   - **Distribution name**: Nhập `StudentWebsiteDistribution`.  
     - **Lý do**: Tên này giúp nhận diện distribution trong danh sách CloudFront, không ảnh hưởng đến domain truy cập.  
     ![Nhập Distribution name.](/images/7-deploying-cloudfront/7.1-creating-a-cloudfront-distribution/creating-a-cloudfront-distribution-03.png)  
     *Hình 3: Nhập Distribution name.*  
   - Nhấn **Next** để tiếp tục.  
     ![Nhấn Next để qua trang tiếp theo.](/images/7-deploying-cloudfront/7.1-creating-a-cloudfront-distribution/creating-a-cloudfront-distribution-04.png)  
     *Hình 4: Nhấn Next để qua trang tiếp theo.*  
   - **Origin**:  
     - **Origin type**: Chọn **Amazon S3**.  
       ![Chọn Origin type Amazon S3.](/images/7-deploying-cloudfront/7.1-creating-a-cloudfront-distribution/creating-a-cloudfront-distribution-05.png)  
       *Hình 5: Chọn Origin type Amazon S3.*  
     - **Origin domain**: Nhấn **Browse S3** và chọn `student-management-website-2025` từ danh sách.  
       - Kết quả: AWS tự động điền `student-management-website-2025.s3.amazonaws.com` (endpoint REST API của S3).  
       - **Lưu ý**: Nếu giao diện hiển thị endpoint **Static Website Hosting** (`student-management-website-2025.s3-website-us-east-1.amazonaws.com`), chọn endpoint REST API (`*.s3.amazonaws.com`) để tương thích với OAI.  
       ![Chọn Origin domain.](/images/7-deploying-cloudfront/7.1-creating-a-cloudfront-distribution/creating-a-cloudfront-distribution-06.png)  
       *Hình 6: Chọn Origin domain.*  
     - **Origin access**:  
       - Chọn **Allow private S3 bucket access to CloudFront – Recommended**.  
       - Chọn **Create a new OAI** hoặc chọn OAI hiện có.  
       - **OAI Name**: Nhập `StudentWebsiteOAI` (hoặc tên tùy chọn).  
       - Chọn **Use recommended origin settings** để tự động cập nhật **Bucket Policy** của `student-management-website-2025`.  
       - Kết quả: AWS tạo OAI và thêm chính sách vào bucket:  
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
       - **Lưu ý**: Xóa chính sách công khai cũ (`Principal: "*"`, mục 6.4) để tăng bảo mật.  
       ![Cấu hình Origin Access Identity.](/images/7-deploying-cloudfront/7.1-creating-a-cloudfront-distribution/creating-a-cloudfront-distribution-07.png)  
       *Hình 7: Cấu hình Origin Access Identity.*  
     - Nhấn **Choose** để xác nhận Origin.  
     - Nhấn **Next**.

4. **Cấu Hình Cache Behavior và Security**  
   - **Default cache behavior**:  
     - **Viewer protocol policy**: Chọn **Redirect HTTP to HTTPS** để đảm bảo truy cập an toàn.  
     - **Allowed HTTP methods**: Chọn **GET, HEAD** (phù hợp cho website tĩnh).  
     - **Cache key and origin requests**: Chọn **CachingOptimized** để tối ưu hiệu suất.  
     - **Compress objects automatically**: Chọn **Yes** để nén nội dung (VD: CSS, JS).  
   - **Web Application Firewall (WAF)**:  
     - Chọn **Enable security protections**.  
     - Chọn **AWS WAF default web ACL** hoặc tạo ACL mới trong AWS WAF (VD: chặn SQL injection, XSS).  
     - **Lý do**: WAF bảo vệ giao diện web khỏi các cuộc tấn công phổ biến.  
     ![Cấu hình Cache Behavior và WAF.](/images/7-deploying-cloudfront/7.1-creating-a-cloudfront-distribution/creating-a-cloudfront-distribution-08.png)  
     *Hình 8: Cấu hình Cache Behavior và WAF.*  
   - Nhấn **Next**.  
     ![Nhấn Next để tiếp tục.](/images/7-deploying-cloudfront/7.1-creating-a-cloudfront-distribution/creating-a-cloudfront-distribution-09.png)  
     *Hình 9: Nhấn Next để tiếp tục.*

5. **Cấu Hình Settings**  
   - **Price class**: Chọn **Use all edge locations** (tối ưu hiệu suất toàn cầu, hoặc chọn khác để giảm chi phí).  
   - **Alternate domain name (CNAME)** (Tùy chọn): Nhập domain tùy chỉnh (VD: `www.student-management.com`) nếu có, yêu cầu cấu hình DNS.  
   - **Default root object**: Nhập `index.html` để phục vụ tệp chính khi truy cập domain CloudFront.  
   - **SSL certificate**: Chọn **Default CloudFront Certificate (*.cloudfront.net)** cho HTTPS.  
   - **Tags** (Tùy chọn): Thêm tag như `Project=StudentManagement`, `Environment=Production`.  
     ![Cấu hình Settings cho CloudFront.](/images/7-deploying-cloudfront/7.1-creating-a-cloudfront-distribution/creating-a-cloudfront-distribution-10.png)  
     *Hình 10: Cấu hình Settings cho CloudFront.*

6. **Tạo Distribution**  
   - Xem lại cấu hình:  
     - **Origin**: `student-management-website-2025.s3.amazonaws.com`.  
     - **Origin access**: OAI (`StudentWebsiteOAI`).  
     - **Viewer protocol policy**: Redirect HTTP to HTTPS.  
     - **Default root object**: `index.html`.  
     - **WAF**: Enabled.  
   - Nhấn **Create distribution**.  
   - Kết quả mong đợi: CloudFront hiển thị thông báo _"Successfully created new distribution"_. Trạng thái ban đầu là **In Progress** (mất 5–15 phút). Sau khi hoàn tất, trạng thái chuyển thành **Enabled**, và bạn nhận **Distribution domain name** (VD: `d12345678.cloudfront.net`).  
     ![Thông báo trạng thái tạo distribution.](/images/7-deploying-cloudfront/7.1-creating-a-cloudfront-distribution/creating-a-cloudfront-distribution-11.png)  
     *Hình 11: Thông báo trạng thái tạo distribution.*

7. **Kiểm Tra Distribution**  
   - Trong **CloudFront > Distributions**, chọn distribution (`StudentWebsiteDistribution`).  
   - Kiểm tra **Status** là **Enabled** và sao chép **Distribution domain name** (VD: `https://d12345678.cloudfront.net`).  
   - Mở trình duyệt, truy cập URL này.  
   - Kết quả mong đợi: Giao diện web hiển thị với biểu mẫu, bảng sinh viên, và nút chức năng (Lưu, Xem, Backup) sử dụng Tailwind CSS và font Poppins.  
     ![Giao diện web qua CloudFront.](/images/7-deploying-cloudfront/7.1-creating-a-cloudfront-distribution/creating-a-cloudfront-distribution-12.png)  
     *Hình 12: Giao diện web qua CloudFront.*  
   - **Xử lý lỗi**:  
     - **Lỗi 403 Forbidden**:  
       - Kiểm tra **Bucket Policy** có đúng OAI ARN (`arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity EXXXXXX`).  
       - Xác minh `index.html`, `styles.css`, `scripts.js` được tải lên S3 (mục 6.2).  
       - Đảm bảo chính sách công khai cũ (`Principal: "*"`) đã bị xóa (mục 6.4).  
     - **Lỗi 404 Not Found**:  
       - Kiểm tra **Default root object** là `index.html` (mục 7.2).  
       - Xác minh **Static Website Hosting** bật với `index.html` làm **Index document** (mục 6.3).  
     - **Giao diện sai**:  
       - Mở **Developer Tools > Console** để kiểm tra lỗi tải `styles.css` hoặc `scripts.js`.  
       - Kiểm tra đường dẫn trong `index.html` (VD: `<link href="styles.css">`, `<script src="scripts.js">`).  
     - **CORS**: Kiểm tra cấu hình CORS trong API Gateway (mục 4.7) với `Access-Control-Allow-Origin: https://d12345678.cloudfront.net`.  
     - **API lỗi**: Kiểm tra `StudentApiKey`, `StudentUsagePlan` (mục 4.9), và log CloudWatch của Lambda.

---

## Lưu Ý Quan Trọng

| Yếu Tố | Chi Tiết |
|--------|----------|
| Bảo mật | OAI đảm bảo chỉ CloudFront truy cập S3. Xóa chính sách công khai (`Principal: "*"`, mục 6.4) và giữ **Block public access** (mục 6.1, trừ **Block public access for bucket policies**). Sử dụng CloudFront Functions để thêm header `x-api-key`: <br> ```javascript <br> function handler(event) { <br>     var request = event.request; <br>     request.headers['x-api-key'] = { value: 'xxxxxxxxxxxxxxxxxxxx' }; <br>     return request; <br> } <br> ``` |
| Tối ưu hóa | Bật **CloudFront Standard Logs** để theo dõi truy cập: Trong **CloudFront > Distribution > General > Logging**, chọn **On**, chỉ định bucket log (VD: `student-web-logs-20250706`). Sử dụng AWS CLI: <br> ```bash <br> aws cloudfront create-distribution --distribution-config file://distribution-config.json <br> ``` |
| Tích hợp với hệ thống | Cập nhật CORS trong API Gateway (mục 4.7) với `Access-Control-Allow-Origin: https://d12345678.cloudfront.net`. Đảm bảo endpoint **POST /students**, **GET /students**, **POST /backup** hoạt động với **Invoke URL** và `StudentApiKey`. |
| Kiểm tra tích hợp | Truy cập CloudFront URL (https://d12345678.cloudfront.net) và kiểm tra: <br> - **POST /students**: Lưu bản ghi, gửi email SES. <br> - **GET /students**: Hiển thị bảng. <br> - **POST /backup**: Tạo tệp trong `student-backup-20250706`, gửi email. <br> Sử dụng **Developer Tools > Network** để kiểm tra yêu cầu API. |
| Xử lý lỗi | **403 Forbidden**: Kiểm tra OAI ARN, **Bucket Policy**, quyền `s3:GetObject`. **404 Not Found**: Xác minh `index.html` là **Default root object**, tệp tồn tại trong S3. **CORS**: Kiểm tra header `Access-Control-Allow-Origin` trong Lambda (mục 3) và API Gateway (mục 4.7). **429**: Kiểm tra giới hạn Rate/Burst/Quota trong `StudentUsagePlan` (mục 4.3). |

> **Mẹo thực tiễn**: Kiểm tra CloudFront URL ngay sau khi trạng thái **Enabled**. Tạo invalidation (mục 7.3) nếu cập nhật tệp S3. Sử dụng AWS CLI để tự động hóa cấu hình.

---

## Kết Luận

CloudFront Distribution đã được tạo với OAI và WAF, phân phối nội dung từ `student-management-website-2025` qua HTTPS. Hệ thống sẵn sàng tích hợp với API `student` và kiểm tra giao diện.

> **Bước tiếp theo**: Chuyển đến [Cấu hình Default Root Object](/7-deploying-cloudfront/7.2-configuring-default-root-object/) để tiếp tục cấu hình!