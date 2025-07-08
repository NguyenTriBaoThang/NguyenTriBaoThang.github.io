---
title: "Khởi Tạo S3 Bucket Mới"
date: 2023-10-25
weight: 1
chapter: false
pre: "<b>6.1 </b>"
---

> **Mục tiêu**: Tạo một Amazon S3 Bucket mới với tên `student-management-website-2025` để lưu trữ các tệp tĩnh (`index.html`, `styles.css`, `scripts.js` từ mục 5) cho giao diện web của ứng dụng Quản Lý Dữ Liệu Sinh Viên. Bucket này sẽ được cấu hình để hỗ trợ **Static Website Hosting** (mục 6.3) và phục vụ nội dung qua CloudFront (mục 7), tích hợp với API `student` (stage `prod`, mục 4.8) để gọi các endpoint **GET /students**, **POST /students**, và **POST /backup** với bảo mật API Key (`StudentApiKey`, mục 4.2) và CORS (mục 4.7).

---

## Tổng Quan về S3 Bucket trong Ứng Dụng

- **Vai trò của bucket `student-management-website-2025`**:  
  - Lưu trữ các tệp tĩnh (`index.html`, `styles.css`, `scripts.js`) cho giao diện web sử dụng Tailwind CSS.  
  - Bật **Static Website Hosting** để cung cấp endpoint truy cập giao diện (sẽ được phân phối qua CloudFront để hỗ trợ HTTPS và hiệu suất cao).  
  - Bỏ chọn **Block all public access** để cho phép cấu hình quyền công khai (`s3:GetObject`) trong **Bucket Policy** (mục 6.4), cần thiết để CloudFront truy xuất nội dung.  
  - Bật **Bucket Versioning** để lưu trữ các phiên bản của tệp, hỗ trợ khôi phục nếu xảy ra lỗi khi cập nhật giao diện.  
- **Tích hợp với hệ thống**:  
  - Giao diện web gọi API `student` (mục 4.8) sử dụng **Invoke URL** (VD: `https://abc123.execute-api.us-east-1.amazonaws.com/prod`) và `StudentApiKey` trong header `x-api-key`.  
  - CORS được cấu hình (mục 4.7) để hỗ trợ yêu cầu từ domain CloudFront (VD: `https://d12345678.cloudfront.net`).  
  - Bucket này khác với bucket `student-backup-20250706` (mục 2.4, 6.5), dùng để lưu trữ tệp backup từ endpoint **POST /backup**.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành mục 2.4 (tạo bucket `student-backup-20250706`), mục 3 (tạo các hàm Lambda `getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`, bảng DynamoDB `studentData`, SES email xác minh), mục 4.1 (tạo API `student`), mục 4.2 (tạo API Key `StudentApiKey`), mục 4.3 (tạo Usage Plan `StudentUsagePlan`), mục 4.4 (tạo phương thức **GET /students**), mục 4.5 (tạo phương thức **POST /students**), mục 4.6 (tạo resource `/backup` và phương thức **POST /backup**), mục 4.7 (kích hoạt CORS), mục 4.8 (triển khai API lên stage `prod`), mục 4.9 (gắn `StudentApiKey` vào `StudentUsagePlan` và liên kết với API `student` stage `prod`), và mục 5 (xây dựng giao diện web với `index.html`, `styles.css`, `scripts.js`). Đảm bảo tài khoản AWS có quyền truy cập S3 (`s3:CreateBucket`, `s3:PutBucketPolicy`) và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console**  
   - Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS của bạn.  
   - Trong thanh tìm kiếm ở đầu trang, nhập **S3** và chọn dịch vụ **Amazon S3** để vào giao diện quản lý bucket.  
   - Kiểm tra vùng AWS: Đảm bảo bạn đang làm việc trong vùng **us-east-1** (US East (N. Virginia)) để đồng bộ với API `student`, các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`), bảng DynamoDB `studentData`, bucket `student-backup-20250706`, và SES. Vùng được hiển thị ở góc trên bên phải AWS Console.  
     ![Giao diện AWS Console với thanh tìm kiếm S3.](/images/6-configuring-s3-buckets/6.1-creating-a-new-s3-bucket/creating-a-new-s3-bucket-01.png)
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm S3.*

2. **Mở Giao Diện Tạo Bucket**  
   - Trong giao diện chính của Amazon S3, nhìn vào menu điều hướng bên trái hoặc phần chính.  
   - Nhấn nút **Create bucket** (thường nằm ở góc trên bên phải) để mở giao diện cấu hình bucket mới.  
   - **Lưu ý**: Nếu giao diện hiển thị danh sách bucket hiện có, kiểm tra xem bucket `student-management-website-2025` đã tồn tại hay chưa để tránh trùng lặp.  
     ![Nút Create bucket trong giao diện S3.](/images/6-configuring-s3-buckets/6.1-creating-a-new-s3-bucket/creating-a-new-s3-bucket-02.png)
     *Hình 2: Nút Create bucket trong giao diện S3.*

3. **Cấu Hình Bucket `student-management-website-2025`**  
   - Trong giao diện **Create bucket**, nhập các thông tin sau:  
     - **Bucket name**: Nhập `student-management-website-2025`.  
       - Tên bucket phải duy nhất toàn cầu (không trùng với bất kỳ bucket nào trong AWS).  
       - Nếu tên bị trùng, thử thêm hậu tố ngẫu nhiên (VD: `student-management-website-20250706-abc123`).  
       - Tên phải tuân thủ quy tắc: chỉ chứa chữ cái thường, số, dấu gạch ngang (-), không chứa khoảng trắng hoặc ký tự đặc biệt khác.  
     - **AWS Region**: Chọn **US East (N. Virginia) us-east-1** để đồng bộ với các dịch vụ khác trong hệ thống.  
     - **Bucket type**: Chọn **General purpose** (phù hợp cho lưu trữ giao diện tĩnh).  
     - **Object Ownership**:  
       - Chọn **ACLs enabled** > **Bucket owner preferred** để hỗ trợ quyền truy cập công khai thông qua **Bucket Policy** (mục 6.4).  
       - Điều này cho phép quản lý quyền bằng Access Control Lists (ACLs) và Bucket Policy, cần thiết để CloudFront truy xuất tệp.  
       ![Cấu hình tên bucket và vùng AWS.](/images/6-configuring-s3-buckets/6.1-creating-a-new-s3-bucket/creating-a-new-s3-bucket-03.png)
       *Hình 3: Cấu hình tên bucket và vùng AWS.*  
     - **Block Public Access settings for this bucket**:  
       - Bỏ chọn **Block all public access** và tất cả các tùy chọn con:  
         - *Block public access to buckets and objects granted through new access control lists*  
         - *Block public access to buckets and objects granted through new public bucket or access point policies*  
         - *Block public access from access points*  
       - **Lý do**: Cần cho phép truy cập công khai (`s3:GetObject`) để CloudFront phục vụ giao diện web. Sau khi cấu hình **Bucket Policy** (mục 6.4), có thể bật lại các tùy chọn không liên quan để tăng bảo mật.  
       ![Bỏ chọn Block Public Access.](/images/6-configuring-s3-buckets/6.1-creating-a-new-s3-bucket/creating-a-new-s3-bucket-04.png)
       *Hình 4: Bỏ chọn Block Public Access.*  
     - **Bucket Versioning**:  
       - Chọn **Enable** để bật **Bucket Versioning**.  
       - **Lý do**: Lưu trữ các phiên bản của tệp (`index.html`, `styles.css`, `scripts.js`) để khôi phục nếu xảy ra lỗi khi cập nhật giao diện (VD: tải nhầm tệp).  
       ![Bật Bucket Versioning.](/images/6-configuring-s3-buckets/6.1-creating-a-new-s3-bucket/creating-a-new-s3-bucket-05.png)
       *Hình 5: Bật Bucket Versioning.*  
     - **Tags (Tùy chọn)**:  
       - Thêm tag để quản lý chi phí, ví dụ: `Project=StudentManagement`, `Environment=Production`.  
     - **Default encryption**:  
       - Chọn **Enable** > **Server-side encryption with Amazon S3-managed keys (SSE-S3)** để mã hóa dữ liệu tại rest, tăng bảo mật cho các tệp giao diện.  
     - **Advanced settings**: Giữ mặc định (không cần cấu hình Object Lock hoặc Multi-Region Access Points cho giao diện tĩnh).  
   - Kiểm tra cấu hình: Xem lại thông tin, đặc biệt là tên bucket, vùng, và cài đặt **Block Public Access**.  
   - Nhấn **Create bucket** để hoàn tất.  
     ![Xem lại và nhấn Create bucket.](/images/6-configuring-s3-buckets/6.1-creating-a-new-s3-bucket/creating-a-new-s3-bucket-06.png)
     *Hình 6: Xem lại và nhấn Create bucket.*

4. **Tạo Bucket**  
   - Sau khi nhấn **Create bucket**, bạn sẽ thấy thông báo: _"Successfully created bucket 'student-management-website-2025'."_  
   - Kết quả mong đợi: Trong danh sách **Buckets**, bucket `student-management-website-2025` xuất hiện với trạng thái mới tạo.  
   - **Xử lý lỗi**:  
     - Nếu gặp lỗi _"Bucket name already exists"_:  
       - Thay tên bucket (VD: `student-management-website-20250706-<random-string>`).  
       - Kiểm tra xem bạn có quyền tạo bucket (`s3:CreateBucket`) trong vai trò IAM.  
     - Nếu gặp lỗi _"AccessDenied"_:  
       - Kiểm tra vai trò IAM của tài khoản AWS có quyền `s3:CreateBucket` và `s3:PutBucketPolicy`.  
     ![Thông báo trạng thái tạo bucket.](/images/6-configuring-s3-buckets/6.1-creating-a-new-s3-bucket/creating-a-new-s3-bucket-07.png)  
     *Hình 7: Thông báo trạng thái tạo bucket.*

5. **Kiểm Tra Bucket**  
   - Trong **S3 > Buckets**, chọn `student-management-website-2025` để xác minh:  
     - **Properties**: Kiểm tra vùng (`us-east-1`), **Bucket Versioning** (Enabled), **Default encryption** (SSE-S3).  
     - **Permissions**: Xác minh **Block all public access** đã bỏ chọn để hỗ trợ cấu hình **Bucket Policy** (mục 6.4).  
   - **Lưu ý**: Bucket này sẽ được sử dụng để tải tệp giao diện (mục 6.2), bật **Static Website Hosting** (mục 6.3), và cấu hình quyền công khai (mục 6.4) trước khi tích hợp với CloudFront.

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Tên bucket** | - Tên `student-management-website-2025` được đề xuất để dễ nhận diện, nhưng phải duy nhất toàn cầu. Nếu trùng, thêm hậu tố ngẫu nhiên (VD: `student-management-website-20250706-abc123`). <br> - Đảm bảo không trùng với bucket backup (`student-backup-20250706`, mục 2.4). |
| **Bảo mật** | - Bỏ chọn **Block all public access** chỉ là tạm thời để cấu hình **Bucket Policy** (mục 6.4). Sau khi cấu hình, có thể bật lại các tùy chọn không liên quan để tăng bảo mật. <br> - Để bảo mật tốt hơn, sử dụng CloudFront **Origin Access Identity (OAI)** thay vì quyền công khai hoàn toàn (mục 6.4). <br> - Không lưu `API_KEY` trong các tệp tĩnh. Sử dụng AWS Secrets Manager hoặc CloudFront Functions để thêm header `x-api-key` (mục 5). |
| **Vùng AWS** | - Đảm bảo vùng `us-east-1` khớp với bucket `student-management-website-2025`, `student-backup-20250706`, API `student`, stage `prod`, các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`), DynamoDB `studentData`, SES, và CloudFront. |
| **Xử lý lỗi** | - Nếu bucket không xuất hiện: Làm mới trang hoặc kiểm tra vùng AWS. <br> - Nếu không thể tạo bucket: Kiểm tra giới hạn bucket trong tài khoản (mặc định 100 bucket/vùng, có thể yêu cầu AWS tăng quota). <br> - Nếu gặp lỗi `AccessDenied`: Kiểm tra vai trò IAM có quyền `s3:CreateBucket` và `s3:PutBucketPolicy`. |
| **Tối ưu hóa** | - Thêm **S3 Access Logs** để theo dõi truy cập: Trong **S3 > student-management-website-2025 > Properties > Server access logging**, chọn **Enable** và chỉ định bucket log (VD: `student-web-logs-20250706`). <br> - Sử dụng AWS CLI hoặc SDK để tự động hóa tạo bucket:
| **Kiểm tra tích hợp** | - Xác minh bucket `student-management-website-2025` tồn tại trong **S3 > Buckets** với đúng vùng (`us-east-1`) và **Bucket Versioning** (Enabled). <br> - Chuẩn bị sẵn các tệp `index.html`, `styles.css`, `scripts.js` (mục 5) để tải lên (mục 6.2). <br> - Sau khi hoàn tất mục 6, truy cập giao diện qua CloudFront URL (VD: `https://d12345678.cloudfront.net`) và kiểm tra các chức năng: <br> - **POST /students**: Lưu bản ghi vào DynamoDB `studentData` và gửi email qua SES. <br> - **GET /students**: Hiển thị bảng sinh viên. <br> - **POST /backup**: Tạo tệp backup trong `student-backup-20250706` và gửi email thông báo. |

> **Mẹo thực tiễn**: Sau khi tạo bucket, kiểm tra ngay trong **S3 > Buckets** để xác minh thông tin. Sử dụng AWS CLI hoặc SDK để tự động hóa nếu cần tạo nhiều bucket. Chuẩn bị tệp giao diện từ mục 5 và kiểm tra quyền IAM trước khi tiếp tục với mục 6.2 (tải tệp lên S3).

---

## Kết Luận

Bucket `student-management-website-2025` đã được tạo thành công trong vùng `us-east-1`, với **Bucket Versioning** và **Default encryption** được bật, sẵn sàng để tải tệp giao diện (mục 6.2), cấu hình **Static Website Hosting** (mục 6.3), và tích hợp với CloudFront.

> **Bước tiếp theo**: Chuyển đến [Tải tài nguyên giao diện lên S3](/6-configuring-s3-buckets/6.2-uploading-static-assets-to-s3/) để tiếp tục cấu hình!