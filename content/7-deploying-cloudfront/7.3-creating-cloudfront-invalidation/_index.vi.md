---
title: "Tạo Invalidation để Làm Mới Nội Dung Cache"
date: 2023-10-25
weight: 3
chapter: false
pre: "<b>7.3. </b>"
---

> **Mục tiêu**: Tạo Invalidation cho CloudFront Distribution `StudentWebsiteDistribution` (mục 7.1) để làm mới nội dung cache, đảm bảo các tệp tĩnh (`index.html`, `styles.css`, `scripts.js`, mục 6.2) từ S3 Bucket `student-management-website-2025` được cập nhật trên domain CloudFront (VD: https://d12345678.cloudfront.net). Điều này giúp người dùng thấy phiên bản mới nhất của giao diện web khi các tệp được sửa đổi, đồng thời duy trì tích hợp với API `student` (stage `prod`, mục 4.8) để thực hiện các chức năng như lưu, xem, và sao lưu dữ liệu. Sau khi tạo invalidation, kiểm tra trạng thái Deploying và giao diện qua **Distribution domain name**.

---

## Tổng Quan về Invalidation

- **Vai trò của Invalidation**:  
  - CloudFront lưu cache nội dung tại các edge locations để tăng tốc độ tải, nhưng khi các tệp trong S3 (`index.html`, `styles.css`, `scripts.js`) được cập nhật, cache cũ có thể khiến người dùng thấy phiên bản lỗi thời.  
  - Invalidation yêu cầu CloudFront xóa cache và lấy phiên bản mới từ S3, đảm bảo giao diện web phản ánh các thay đổi.  
  - Sử dụng đường dẫn `/*` để làm mới toàn bộ nội dung cache trong distribution, phù hợp khi cập nhật nhiều tệp hoặc không xác định được tệp cụ thể.  
- **Tích hợp với hệ thống**:  
  - CloudFront phân phối các tệp tĩnh từ S3 Bucket `student-management-website-2025` (mục 6.1–6.4) thông qua **Origin Access Identity (OAI)** (mục 7.1), với `index.html` là **Default Root Object** (mục 7.2).  
  - Giao diện web gọi API `student` (mục 4.8) với **Invoke URL** (VD: https://abc123.execute-api.us-east-1.amazonaws.com/prod) và `StudentApiKey` (mục 4.2).  
  - Các chức năng:  
    - **POST /students**: Lưu bản ghi vào DynamoDB `studentData` và gửi email qua SES.  
    - **GET /students**: Hiển thị dữ liệu trong bảng.  
    - **POST /backup**: Tạo tệp trong S3 Bucket `student-backup-20250706` (mục 6.5) và gửi email thông báo.  
  - CORS được cấu hình (mục 4.7) để hỗ trợ yêu cầu từ domain CloudFront (VD: https://d12345678.cloudfront.net).

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành mục 7.1 (tạo CloudFront Distribution `StudentWebsiteDistribution`), mục 7.2 (cấu hình **Default Root Object**), mục 6.1 (tạo bucket `student-management-website-2025`), mục 6.2 (tải lên `index.html`, `styles.css`, `scripts.js`), mục 6.3 (bật **Static Website Hosting**), mục 6.4 (cấu hình **Bucket Policy**), mục 6.5 (cấu hình bucket `student-backup-20250706`), mục 5 (xây dựng giao diện web), mục 4.1 (tạo API `student`), mục 4.2 (tạo API Key `StudentApiKey`), mục 4.3 (tạo Usage Plan `StudentUsagePlan`), mục 4.4 (tạo phương thức **GET /students**), mục 4.5 (tạo phương thức **POST /students**), mục 4.6 (tạo resource `/backup` và phương thức **POST /backup**), mục 4.7 (kích hoạt CORS), mục 4.8 (triển khai API lên stage `prod`), mục 4.9 (gắn `StudentApiKey` vào `StudentUsagePlan`). Đảm bảo tài khoản AWS có quyền `cloudfront:CreateInvalidation`, `s3:GetObject`, và vùng AWS là `us-east-1` cho các dịch vụ liên quan.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console**  
   - Đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS.  
   - Trong thanh tìm kiếm, nhập **CloudFront** và chọn dịch vụ **Amazon CloudFront**.  
   - Kiểm tra vùng AWS: CloudFront là dịch vụ toàn cầu, nhưng đảm bảo S3 Bucket `student-management-website-2025`, API `student`, Lambda, DynamoDB, và SES ở `us-east-1`.  
     ![Giao diện AWS Console với thanh tìm kiếm CloudFront.](/images/7-deploying-cloudfront/7.3-creating-cloudfront-invalidation/creating-cloudfront-invalidation-01.png)  
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm CloudFront.*

2. **Chọn CloudFront Distribution**  
   - Trong **CloudFront > Distributions**, tìm và chọn distribution có tên `StudentWebsiteDistribution` (tạo ở mục 7.1).  
     - **Nhận diện**: Distribution có ID bắt đầu bằng `E...` và **Domain name** dạng `d12345678.cloudfront.net`.  
   - Nhấn vào ID hoặc tên distribution để vào giao diện chi tiết.  
   - Kiểm tra trạng thái: Đảm bảo distribution ở trạng thái **Enabled**. Nếu vẫn là **In Progress**, chờ 5–15 phút để triển khai hoàn tất (mục 7.1).  
     ![Chọn CloudFront Distribution.](/images/7-deploying-cloudfront/7.3-creating-cloudfront-invalidation/creating-cloudfront-invalidation-02.png)  
     *Hình 2: Chọn CloudFront Distribution.*

3. **Truy Cập Tab Invalidations**  
   - Trong giao diện chi tiết của `StudentWebsiteDistribution`, chọn tab **Invalidations** (thường nằm ở đầu trang, bên cạnh **General**, **Behaviors**, v.v.).  
   - Tab **Invalidations** hiển thị danh sách các invalidation đã tạo (nếu có), với các cột như **ID**, **Status** (**In Progress** hoặc **Completed**), và **Last modified**.  

4. **Tạo Invalidation**  
   - Trong tab **Invalidations**, nhấn nút **Create invalidation**.  
     ![Nút Create invalidation trong tab Invalidations.](/images/7-deploying-cloudfront/7.3-creating-cloudfront-invalidation/creating-cloudfront-invalidation-03.png)  
     *Hình 3: Nút Create invalidation trong tab Invalidations.*  
   - Trong giao diện **Create invalidation**, tại trường **Add object paths**, nhập `/*`.  
     - **Lý do**:  
       - Đường dẫn `/*` yêu cầu CloudFront làm mới toàn bộ nội dung cache trong distribution, đảm bảo tất cả các tệp (`index.html`, `styles.css`, `scripts.js`) được lấy phiên bản mới nhất từ S3.  
       - Phù hợp khi cập nhật nhiều tệp hoặc không xác định được tệp cụ thể đã thay đổi (VD: sau khi tải lên phiên bản mới của `styles.css` hoặc `scripts.js` trong mục 6.2).  
     - **Tùy chọn**: Nếu chỉ cập nhật một tệp, nhập đường dẫn cụ thể (VD: `/index.html`, `/styles.css`) để giảm chi phí invalidation.  
   - Nhấn **Create invalidation**.  
     ![Cấu hình đường dẫn /* cho invalidation.](/images/7-deploying-cloudfront/7.3-creating-cloudfront-invalidation/creating-cloudfront-invalidation-04.png)  
     *Hình 4: Cấu hình đường dẫn /* cho invalidation.*  
   - Kết quả mong đợi: CloudFront tạo invalidation mới, hiển thị trong tab **Invalidations** với trạng thái **In Progress** và thông báo _"Successfully created invalidation"_.  
     ![Thông báo tạo invalidation thành công.](/images/7-deploying-cloudfront/7.3-creating-cloudfront-invalidation/creating-cloudfront-invalidation-05.png)  
     *Hình 5: Thông báo tạo invalidation thành công.*

5. **Kiểm Tra Trạng Thái Invalidation**  
   - Trong tab **Invalidations**, kiểm tra cột **Last modified** của invalidation vừa tạo.  
   - Trạng thái ban đầu: **In Progress** (CloudFront đang xóa cache tại các edge locations, mất 1–5 phút).  
     ![Trạng thái In Progress của invalidation.](/images/7-deploying-cloudfront/7.3-creating-cloudfront-invalidation/creating-cloudfront-invalidation-06.png)  
     *Hình 6: Trạng thái In Progress của invalidation.*  
   - Trạng thái hoàn tất: **Completed** (cache đã được làm mới, nội dung mới sẵn sàng).  
     ![Trạng thái Completed của invalidation.](/images/7-deploying-cloudfront/7.3-creating-cloudfront-invalidation/creating-cloudfront-invalidation-07.png)  
     *Hình 7: Trạng thái Completed của invalidation.*  
   - **Xử lý lỗi**:  
     - **Invalidation không tạo được**: Kiểm tra vai trò IAM có quyền `cloudfront:CreateInvalidation`:  
       ```json
       {
           "Version": "2012-10-17",
           "Statement": [
               {
                   "Effect": "Allow",
                   "Action": "cloudfront:CreateInvalidation",
                   "Resource": "arn:aws:cloudfront::<AWS_ACCOUNT_ID>:distribution/<DISTRIBUTION_ID>"
               }
           ]
       }
       ```  
       - Thay `<AWS_ACCOUNT_ID>` và `<DISTRIBUTION_ID>` bằng giá trị thực (tìm trong CloudFront > Distributions).  
     - **Trạng thái không chuyển sang Completed**:  
       - Chờ thêm 5–10 phút, vì thời gian xử lý phụ thuộc vào số lượng edge locations.  
       - Tạo lại invalidation nếu cần.

6. **Truy Cập Distribution Domain Name để Kiểm Tra**  
   - Trong **CloudFront > Distributions**, sao chép **Distribution domain name** của `StudentWebsiteDistribution` (VD: `https://d12345678.cloudfront.net`).  
   - Mở trình duyệt và truy cập URL này.  
   - Kết quả mong đợi:  
     - Giao diện web hiển thị phiên bản mới nhất của `index.html`, `styles.css`, và `scripts.js` (nếu đã cập nhật trong S3, mục 6.2).  
     - Biểu mẫu nhập liệu, bảng sinh viên, và các nút chức năng (Lưu, Xem, Backup) hiển thị đúng, sử dụng Tailwind CSS và font Poppins.  
   - **Ví dụ kiểm tra**:  
     - Tải lên phiên bản mới của `styles.css` (VD: đổi màu gradient) hoặc `index.html` (VD: thêm trường mới) vào S3 Bucket `student-management-website-2025` (mục 6.2).  
     - Tạo invalidation với `/*`.  
     - Truy cập CloudFront URL và xác minh giao diện phản ánh thay đổi (VD: gradient mới hoặc trường mới hiển thị).  
     ![Giao diện web qua CloudFront sau invalidation.](/images/7-deploying-cloudfront/7.3-creating-cloudfront-invalidation/creating-cloudfront-invalidation-08.png)  
     *Hình 8: Giao diện web qua CloudFront sau invalidation.*

7. **Kiểm Tra Giao Diện và Chức Năng API**  
   - Kiểm tra giao diện web qua CloudFront URL (VD: `https://d12345678.cloudfront.net`):  
     - **Giao diện hiển thị**:  
       - Biểu mẫu nhập liệu (hỗ trợ các trường `studentid`, `name`, `class`, `birthdate`, `email`) hoạt động đúng.  
       - Bảng sinh viên hiển thị dữ liệu từ API **GET /students**.  
       - Các nút chức năng (Lưu, Xem, Backup) hoạt động, sử dụng Tailwind CSS và font Poppins.  
     - **Chức năng API**:  
       - **Lưu dữ liệu sinh viên**: Nhập dữ liệu vào biểu mẫu, nhấn Lưu, kiểm tra bản ghi được lưu vào DynamoDB `studentData` và nhận email xác nhận qua SES.  
         ```bash
         curl -X POST https://abc123.execute-api.us-east-1.amazonaws.com/prod/students \
             -H "x-api-key: xxxxxxxxxxxxxxxxxxxx" \
             -H "Content-Type: application/json" \
             -d '{"studentid":"SV005","name":"Pham Thi E","class":"CNTT05","birthdate":"2001-05-05","email":"student5@example.com"}'
         ```  
       - **Xem danh sách sinh viên**: Nhấn Xem, kiểm tra bảng hiển thị dữ liệu từ API **GET /students**.  
         ```bash
         curl -X GET https://abc123.execute-api.us-east-1.amazonaws.com/prod/students \
             -H "x-api-key: xxxxxxxxxxxxxxxxxxxx"
         ```  
       - **Backup dữ liệu**: Nhấn Backup, kiểm tra tệp được tạo trong S3 Bucket `student-backup-20250706` và nhận email thông báo qua SES.  
         ```bash
         curl -X POST https://abc123.execute-api.us-east-1.amazonaws.com/prod/backup \
             -H "x-api-key: xxxxxxxxxxxxxxxxxxxx" \
             -H "Content-Type: application/json"
         ```  
   - **Xử lý lỗi**:  
     - **Nội dung không cập nhật**:  
       - Kiểm tra trạng thái invalidation là **Completed** trong tab **Invalidations**.  
       - Tạo lại invalidation với `/*` nếu cần.  
       - Xác minh tệp mới (`index.html`, `styles.css`, `scripts.js`) được tải lên S3 đúng cách (mục 6.2).  
       - Kiểm tra **Bucket Policy** (mục 7.1) cho phép OAI truy cập:  
         ```json
         {
             "Version": "2012-10-17",
             "Statement": [
                 {
                     "Sid": "AllowCloudFrontOAI",
                     "Effect": "Allow",
                     "Principal": {
                         "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity <OAI_ID>"
                     },
                     "Action": "s3:GetObject",
                     "Resource": "arn:aws:s3:::student-management-website-2025/*"
                 }
             ]
         }
         ```  
     - **Lỗi 403 Forbidden**:  
       - Kiểm tra OAI (mục 7.1) được cấu hình đúng trong CloudFront và **Bucket Policy** của S3.  
       - Đảm bảo `index.html`, `styles.css`, `scripts.js` được tải lên S3 (mục 6.2).  
       - Xác minh **Block public access** được bật (trừ **Block public access for bucket policies**) trong S3 (mục 7.1).  
     - **Lỗi 404 Not Found**:  
       - Kiểm tra **Default Root Object** là `index.html` (mục 7.2).  
       - Xác minh **Static Website Hosting** (mục 6.3) bật với `index.html` làm **Index document** trong S3.  
     - **Giao diện hiển thị sai**:  
       - Mở **Developer Tools > Console** để kiểm tra lỗi tải `styles.css` hoặc `scripts.js`.  
       - Kiểm tra đường dẫn trong `index.html` (VD: `<link href="styles.css">`, `<script src="scripts.js">`) khớp với cấu trúc thư mục trong S3.  
     - **Lỗi CORS khi gọi API**:  
       - Kiểm tra cấu hình CORS trong API Gateway (mục 4.7) có `Access-Control-Allow-Origin: https://d12345678.cloudfront.net`.  
       - Đảm bảo `scripts.js` gửi yêu cầu API với đúng **Invoke URL** (VD: https://abc123.execute-api.us-east-1.amazonaws.com/prod) và header `x-api-key: <StudentApiKey>`.  
     - **Lỗi 403/429 khi gọi API**:  
       - **403**: Kiểm tra `StudentApiKey` và `StudentUsagePlan` (mục 4.9).  
       - **429**: Kiểm tra giới hạn Rate/Burst/Quota trong `StudentUsagePlan` (mục 4.3).

---

## Lưu Ý Quan Trọng

| Yếu Tố | Chi Tiết |
|--------|----------|
| Bảo mật | Đảm bảo **Bucket Policy** chỉ cho phép OAI truy cập S3 (mục 7.1). Tránh nhúng `StudentApiKey` trong `scripts.js`. Sử dụng CloudFront Functions để thêm header `x-api-key`: <br> ```javascript <br> function handler(event) { <br>     var request = event.request; <br>     request.headers['x-api-key'] = { value: 'xxxxxxxxxxxxxxxxxxxx' }; <br>     return request; <br> } <br> ``` |
| Tối ưu hóa | Bật **CloudFront Standard Logs** để theo dõi truy cập: Trong **CloudFront > Distribution > General > Logging**, chọn **On**, chỉ định bucket log (VD: `student-web-logs-20250706`). Sử dụng AWS CLI để tự động hóa invalidation: <br> ```bash <br> aws cloudfront create-invalidation --distribution-id <DISTRIBUTION_ID> --paths "/*" <br> ``` |
| Tích hợp với hệ thống | Cập nhật CORS trong API Gateway (mục 4.7) với `Access-Control-Allow-Origin: https://d12345678.cloudfront.net`. Đảm bảo endpoint **POST /students**, **GET /students**, **POST /backup** hoạt động với **Invoke URL** và `StudentApiKey`. |
| Kiểm tra tích hợp | Truy cập CloudFront URL (https://d12345678.cloudfront.net) và kiểm tra: <br> - **POST /students**: Lưu bản ghi, gửi email SES. <br> - **GET /students**: Hiển thị bảng. <br> - **POST /backup**: Tạo tệp trong `student-backup-20250706`, gửi email. <br> Sử dụng **Developer Tools > Network** để kiểm tra yêu cầu API. |
| Xử lý lỗi | **Nội dung không cập nhật**: Kiểm tra trạng thái invalidation, tệp S3, **Bucket Policy**. **403 Forbidden**: Kiểm tra OAI, **Bucket Policy**, quyền `s3:GetObject`. **404 Not Found**: Xác minh `index.html` là **Default Root Object**, tệp tồn tại trong S3. **CORS**: Kiểm tra header `Access-Control-Allow-Origin` trong Lambda (mục 3) và API Gateway (mục 4.7). **429**: Kiểm tra giới hạn Rate/Burst/Quota trong `StudentUsagePlan` (mục 4.3). |

> **Mẹo thực tiễn**: Tạo invalidation mỗi khi cập nhật tệp trong S3. Kiểm tra CloudFront URL ngay sau khi trạng thái invalidation là **Completed**. Sử dụng AWS CLI để tự động hóa: `aws cloudfront create-invalidation --distribution-id <DISTRIBUTION_ID> --paths "/*"`.

---

## Kết Luận

Invalidation đã được tạo cho CloudFront Distribution `StudentWebsiteDistribution`, đảm bảo nội dung cache được làm mới và giao diện web hiển thị phiên bản mới nhất từ S3. Hệ thống tích hợp với API `student` sẵn sàng hoạt động.

> **Bước tiếp theo**: > Chuyển đến [Thiết lập Backup hệ thống](/88-setting-up-system-backup/) để bắt đầu triển khai Backup hệ thống!