---
title: "Cập Nhật Bucket Policy để Hỗ Trợ Sao Lưu Dữ Liệu (Backup)"
date: 2025-07-09
weight: 5
chapter: false
pre: "<b>6.5. </b>"
---

> **Mục tiêu**: Tạo S3 Bucket `student-backup-20250706` (nếu chưa được tạo ở mục 2.4) và cấu hình **Bucket Policy** để cho phép hàm Lambda `BackupDynamoDBAndSendEmail` (với vai trò `DynamoDBBackupRole`, mục 3.3) ghi tệp backup (JSON/CSV) vào bucket thông qua endpoint **POST /backup** (mục 4.6). Bucket này lưu trữ dữ liệu sao lưu từ bảng DynamoDB `studentData` và tích hợp với SES để gửi email thông báo. Bucket không cần truy cập công khai, chỉ cần quyền `s3:PutObject` cho vai trò `DynamoDBBackupRole`, đảm bảo bảo mật và tích hợp mượt mà với hệ thống serverless.

---

## Tổng Quan về Bucket Sao Lưu

- **Vai trò của bucket `student-backup-20250706`**:  
  - Lưu trữ các tệp backup (JSON/CSV) được tạo bởi hàm Lambda `BackupDynamoDBAndSendEmail` khi gọi endpoint **POST /backup**.  
  - Được cấu hình để chỉ cho phép vai trò `DynamoDBBackupRole` ghi tệp (`s3:PutObject`, `s3:PutObjectAcl`), không cho phép truy cập công khai.  
  - Tích hợp với API `student` (stage `prod`, mục 4.8) và SES để gửi email thông báo sau khi sao lưu.  
- **Tích hợp với hệ thống**:  
  - Hàm Lambda `BackupDynamoDBAndSendEmail` (mục 3.3):  
    - Đọc dữ liệu từ DynamoDB `studentData` (`dynamodb:Scan`, `dynamodb:Query`).  
    - Ghi tệp backup vào `student-backup-20250706` (`s3:PutObject`).  
    - Gửi email thông báo qua SES (`ses:SendEmail`, `ses:SendRawEmail`).  
  - Endpoint **POST /backup** (mục 4.6) được gọi từ giao diện web (tệp `scripts.js`, mục 6.2) thông qua **Invoke URL** (VD: https://abc123.execute-api.us-east-1.amazonaws.com/prod/backup) với header `x-api-key: <StudentApiKey>` (mục 4.2).  
  - CORS được cấu hình (mục 4.7) để hỗ trợ yêu cầu từ domain CloudFront (VD: https://d12345678.cloudfront.net).  
- **Lý do không cho phép truy cập công khai**:  
  - Bucket `student-backup-20250706` chỉ cần quyền ghi từ Lambda, không cần truy cập công khai như bucket `student-management-website-2025` (mục 6.4).  
  - **Block all public access** được bật để tăng bảo mật, chỉ cho phép vai trò `DynamoDBBackupRole` truy cập.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành mục 2.4 (tạo bucket `student-backup-20250706`), mục 3.3 (tạo hàm Lambda `BackupDynamoDBAndSendEmail` với vai trò `DynamoDBBackupRole`), mục 4.1 (tạo API `student`), mục 4.2 (tạo API Key `StudentApiKey`), mục 4.3 (tạo Usage Plan `StudentUsagePlan`), mục 4.6 (tạo resource `/backup` và phương thức **POST /backup**), mục 4.7 (kích hoạt CORS), mục 4.8 (triển khai API lên stage `prod`), mục 4.9 (gắn `StudentApiKey` vào `StudentUsagePlan`), mục 5 (xây dựng giao diện web với `scripts.js`), mục 6.1 (tạo bucket `student-management-website-2025`). Đảm bảo tài khoản AWS có quyền `s3:CreateBucket`, `s3:PutBucketPolicy`, và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console**  
   - Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS của bạn.  
   - Trong thanh tìm kiếm ở đầu trang, nhập **S3** và chọn dịch vụ **Amazon S3** để vào giao diện quản lý bucket.  
   - Kiểm tra vùng AWS: Đảm bảo bạn đang làm việc trong vùng **us-east-1** (US East (N. Virginia)) để đồng bộ với bucket `student-backup-20250706`, API `student`, các hàm Lambda (`getStudentData`, `insertStudentData`, `BackupDynamoDBAndSendEmail`), bảng DynamoDB `studentData`, và SES. Vùng được hiển thị ở góc trên bên phải AWS Console.  
     ![Giao diện AWS Console với thanh tìm kiếm S3.](/images/6-configuring-s3-buckets/6.5-updating-bucket-policy-to-support-backup/updating-bucket-policy-to-support-backup-01.png)  
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm S3.*

2. **Tạo Bucket `student-backup-20250706`**  
   - Kiểm tra bucket hiện có: Trong **S3 > Buckets**, tìm bucket `student-backup-20250706` (giả định đã tạo ở mục 2.4). Nếu đã tồn tại, bỏ qua bước tạo và chuyển sang Bước 3.  
   - Trong giao diện chính của **Amazon S3**, nhấn nút **Create bucket** (thường nằm ở góc trên bên phải).  
     ![Nút Create bucket trong giao diện S3.](/images/6-configuring-s3-buckets/6.5-updating-bucket-policy-to-support-backup/updating-bucket-policy-to-support-backup-02.png)  
     *Hình 2: Nút Create bucket trong giao diện S3.*  
   - Trong giao diện **Create bucket**, nhập các thông tin sau:  
     - **Bucket name**: Nhập `student-backup-20250706`.  
       - Tên bucket phải duy nhất toàn cầu. Nếu trùng, thử thêm hậu tố ngẫu nhiên (VD: `student-backup-20250706-abc123`).  
       - Tên chỉ chứa chữ cái thường, số, dấu gạch ngang (-), không chứa khoảng trắng hoặc ký tự đặc biệt.  
     - **AWS Region**: Chọn **US East (N. Virginia) us-east-1** để đồng bộ với các dịch vụ khác.  
     - **Bucket type**: Chọn **General purpose** (phù hợp cho lưu trữ tệp backup).  
     - **Object Ownership**: Chọn **ACLs disabled** (khuyến nghị cho bucket không công khai) để quản lý quyền qua **Bucket Policy** và IAM.  
     - **Block Public Access settings for this bucket**: Giữ **Block all public access** được chọn (mặc định) để đảm bảo bucket không cho phép truy cập công khai.  
       ![Bỏ chọn Block Public Access.](/images/6-configuring-s3-buckets/6.5-updating-bucket-policy-to-support-backup/updating-bucket-policy-to-support-backup-04.png)  
       *Hình 3: Bỏ chọn Block Public Access.*  
     - **Bucket Versioning**: Chọn **Disable** (theo yêu cầu).  
       - **Lưu ý**: Khuyến nghị bật **Enable** để lưu trữ các phiên bản của tệp backup, hỗ trợ khôi phục nếu xảy ra lỗi ghi. Nếu bật, sử dụng AWS CLI:  
         ```bash
         aws s3api put-bucket-versioning --bucket student-backup-20250706 --versioning-configuration Status=Enabled
         ```  
       ![Bật Bucket Versioning.](/images/6-configuring-s3-buckets/6.5-updating-bucket-policy-to-support-backup/updating-bucket-policy-to-support-backup-05.png)  
       *Hình 4: Bật Bucket Versioning.*  
     - **Default encryption**: Chọn **Enable** > **Server-side encryption with Amazon S3-managed keys (SSE-S3)** để mã hóa dữ liệu tại rest, tăng bảo mật.  
     - **Tags** (Tùy chọn): Thêm tag để quản lý chi phí, ví dụ: `Project=StudentManagement`, `Environment=Production`.  
   - Nhấn **Create bucket**.  
     ![Xem lại và nhấn Create bucket.](/images/6-configuring-s3-buckets/6.5-updating-bucket-policy-to-support-backup/updating-bucket-policy-to-support-backup-06.png)  
     *Hình 5: Xem lại và nhấn Create bucket.*  
   - Kết quả mong đợi: AWS S3 hiển thị thông báo _"Successfully created bucket 'student-backup-20250706'"_.  
     ![Thông báo trạng thái tạo bucket.](/images/6-configuring-s3-buckets/6.5-updating-bucket-policy-to-support-backup/updating-bucket-policy-to-support-backup-07.png)  
     *Hình 6: Thông báo trạng thái tạo bucket.*  
   - **Xử lý lỗi**:  
     - **"Bucket name already exists"**: Thay tên bucket (VD: `student-backup-20250706-<random-string>`). Kiểm tra quyền `s3:CreateBucket` trong vai trò IAM.  
     - **"AccessDenied"**: Kiểm tra vai trò IAM có quyền `s3:CreateBucket`:  
       ```json
       {
           "Version": "2012-10-17",
           "Statement": [
               {
                   "Effect": "Allow",
                   "Action": "s3:CreateBucket",
                   "Resource": "*"
               }
           ]
       }
       ```

3. **Truy Cập Tab Permissions của Bucket**  
   - Trong **S3 > Buckets**, chọn bucket `student-backup-20250706`.  
   - Chọn tab **Permissions** (thường nằm ở đầu trang, bên cạnh Objects, Properties, v.v.).  
   - Cuộn xuống phần **Bucket policy** để xem trạng thái hiện tại (mặc định là trống nếu chưa cấu hình).  
     ![Tab Permissions và phần Bucket policy.](/images/6-configuring-s3-buckets/6.5-updating-bucket-policy-to-support-backup/updating-bucket-policy-to-support-backup-03.png)  
     *Hình 7: Tab Permissions và phần Bucket policy.*

4. **Chỉnh Sửa Bucket Policy**  
   - Trong phần **Bucket policy**, nhấn nút **Edit** để mở giao diện chỉnh sửa.  
   - Dán mã JSON sau để cho phép vai trò `DynamoDBBackupRole` ghi tệp (`s3:PutObject`, `s3:PutObjectAcl`):  
     ```json
     {
         "Version": "2012-10-17",
         "Statement": [
             {
                 "Sid": "AllowLambdaPutObject",
                 "Effect": "Allow",
                 "Principal": {
                     "AWS": "arn:aws:iam::<AWS_ACCOUNT_ID>:role/DynamoDBBackupRole"
                 },
                 "Action": [
                     "s3:PutObject",
                     "s3:PutObjectAcl"
                 ],
                 "Resource": "arn:aws:s3:::student-backup-20250706/*"
             }
         ]
     }
     ```  
   - **Giải thích mã JSON**:  
     - **Version**: "2012-10-17" là phiên bản định dạng chính sách IAM mới nhất.  
     - **Statement**: Danh sách các chính sách quyền.  
     - **Sid**: "AllowLambdaPutObject" là tên tùy chọn để nhận diện chính sách.  
     - **Effect**: "Allow" cho phép hành động được chỉ định.  
     - **Principal**: "arn:aws:iam::<AWS_ACCOUNT_ID>:role/DynamoDBBackupRole" chỉ định vai trò IAM của Lambda `BackupDynamoDBAndSendEmail`.  
     - **Action**:  
       - `s3:PutObject`: Cho phép ghi tệp backup vào bucket.  
       - `s3:PutObjectAcl`: Cho phép đặt quyền ACL trên tệp (nếu cần).  
     - **Resource**: "arn:aws:s3:::student-backup-20250706/*" chỉ định tất cả các tệp trong bucket `student-backup-20250706`.  
   - **Thay `<AWS_ACCOUNT_ID>`**:  
     - Tìm ID tài khoản AWS trong **IAM > Users** hoặc **Account** (VD: 123456789012).  
     - Thay vào ARN: `arn:aws:iam::123456789012:role/DynamoDBBackupRole`.  
   - Kiểm tra mã: Đảm bảo ARN trong **Resource** và **Principal** đúng cú pháp và khớp với bucket/role thực tế.  
     ![Cấu hình Bucket Policy.](/images/6-configuring-s3-buckets/6.5-updating-bucket-policy-to-support-backup/updating-bucket-policy-to-support-backup-04.png)  
     *Hình 8: Cấu hình Bucket Policy.*

5. **Lưu Thay Đổi**  
   - Nhấn **Save changes** để áp dụng **Bucket Policy**.  
   - Kết quả mong đợi: AWS S3 hiển thị thông báo _"Successfully edited bucket policy"_.  
     ![Nhấn Save changes.](/images/6-configuring-s3-buckets/6.5-updating-bucket-policy-to-support-backup/updating-bucket-policy-to-support-backup-05.png)  
     *Hình 9: Nhấn Save changes.*  
   - **Xử lý lỗi**:  
     - **"Policy has invalid resource"**: Kiểm tra ARN trong **Resource** đúng cú pháp (`arn:aws:s3:::student-backup-20250706/*`).  
     - **"Invalid principal in policy"**: Xác minh ARN của `DynamoDBBackupRole` đúng và vai trò tồn tại trong IAM.  
     - **"AccessDenied"**: Kiểm tra vai trò IAM của tài khoản có quyền `s3:PutBucketPolicy`:  
       ```json
       {
           "Version": "2012-10-17",
           "Statement": [
               {
                   "Effect": "Allow",
                   "Action": "s3:PutBucketPolicy",
                   "Resource": "arn:aws:s3:::student-backup-20250706"
               }
           ]
       }
       ```

6. **Kiểm Tra Quyền Lambda**  
   - Xác minh vai trò `DynamoDBBackupRole`:  
     - Trong **IAM > Roles**, tìm `DynamoDBBackupRole` (tạo ở mục 3.3).  
     - Đảm bảo vai trò có quyền `s3:PutObject` và `s3:PutObjectAcl` cho bucket `student-backup-20250706`:  
       ```json
       {
           "Version": "2012-10-17",
           "Statement": [
               {
                   "Effect": "Allow",
                   "Action": [
                       "s3:PutObject",
                       "s3:PutObjectAcl"
                   ],
                   "Resource": "arn:aws:s3:::student-backup-20250706/*"
               }
           ]
       }
       ```  
   - Kiểm tra endpoint **POST /backup**:  
     - Gọi endpoint bằng curl để xác minh hàm Lambda ghi tệp backup:  
       ```bash
       curl -X POST https://abc123.execute-api.us-east-1.amazonaws.com/prod/backup \
           -H "x-api-key: xxxxxxxxxxxxxxxxxxxx" \
           -H "Content-Type: application/json"
       ```  
     - Kết quả mong đợi:  
       - Tệp backup (JSON/CSV) được tạo trong **S3 > student-backup-20250706 > Objects** (VD: `backup-20250706.json`).  
       - Email thông báo được gửi qua SES (kiểm tra hộp thư, bao gồm Spam/Junk).  
     - **Xử lý lỗi**:  
       - **Lỗi 403 Forbidden**:  
         - Kiểm tra ARN trong **Bucket Policy** (**Resource** và **Principal**) khớp với bucket và vai trò.  
         - Xác minh `DynamoDBBackupRole` có quyền `s3:PutObject` và được gắn vào Lambda `BackupDynamoDBAndSendEmail`.  
       - **Tệp backup không xuất hiện**:  
         - Kiểm tra log CloudWatch của Lambda (`/aws/lambda/BackupDynamoDBAndSendEmail`) để tìm lỗi.  
         - Xác minh endpoint **POST /backup** trả về mã 200 và không có lỗi CORS.  
       - **Lỗi CORS**:  
         - Kiểm tra header `Access-Control-Allow-Origin` trong Lambda (mục 3.3) và API Gateway (mục 4.7).  
         - Đảm bảo CORS hỗ trợ domain CloudFront (VD: https://d12345678.cloudfront.net).  

---

## Lưu Ý Quan Trọng

| Yếu Tố | Chi Tiết |
|--------|----------|
| Bảo mật | Giữ **Block all public access** bật để đảm bảo bucket `student-backup-20250706` không bị truy cập công khai. Chỉ vai trò `DynamoDBBackupRole` được phép ghi tệp. Tránh nhúng `StudentApiKey` trong `scripts.js`; sử dụng AWS Secrets Manager hoặc CloudFront Functions: <br> function handler(event) { var request = event.request; request.headers['x-api-key'] = { value: 'xxxxxxxxxxxxxxxxxxxx' }; return request; } |
| Tối ưu hóa | Bật **S3 Access Logs**: Trong S3 > student-backup-20250706 > Properties > Server access logging, chọn **Enable**, chỉ định bucket log (VD: student-backup-logs-20250706). Sử dụng AWS CLI để tự động hóa: <br> aws s3api put-bucket-policy --bucket student-backup-20250706 --policy file://policy.json |
| Tích hợp với hệ thống | Đảm bảo endpoint **POST /backup** hoạt động với **Invoke URL** và `StudentApiKey`. Cập nhật CORS trong API Gateway (mục 4.7) với `Access-Control-Allow-Origin: https://d12345678.cloudfront.net`. Tích hợp với CloudFront (mục 7) để gọi API từ giao diện web. |
| Kiểm tra tích hợp | Gọi **POST /backup** từ giao diện web (https://d12345678.cloudfront.net) hoặc curl. Kiểm tra: <br> - Tệp backup xuất hiện trong `student-backup-20250706`. <br> - Email SES được gửi. <br> Sử dụng **Developer Tools > Network** để kiểm tra yêu cầu API. |
| Xử lý lỗi | **403 Forbidden**: Kiểm tra ARN trong **Bucket Policy**, quyền `s3:PutObject` của `DynamoDBBackupRole`. **Tệp không xuất hiện**: Kiểm tra log CloudWatch, mã Lambda. **CORS**: Kiểm tra header `Access-Control-Allow-Origin` trong Lambda (mục 3.3) và API Gateway (mục 4.7). **429**: Kiểm tra giới hạn Rate/Burst/Quota trong `StudentUsagePlan` (mục 4.3). |

> **Mẹo thực tiễn**: Kiểm tra **Bucket Policy** và quyền IAM của `DynamoDBBackupRole` trước khi gọi **POST /backup**. Sử dụng AWS CLI để tự động hóa nếu cần áp dụng chính sách cho nhiều bucket. Chuẩn bị cho mục 7 (cấu hình CloudFront) để hoàn thiện tích hợp.

---

## Kết Luận

Bucket `student-backup-20250706` đã được tạo và cấu hình **Bucket Policy** để cho phép hàm Lambda `BackupDynamoDBAndSendEmail` ghi tệp backup. Bucket sẵn sàng tích hợp với endpoint **POST /backup** và CloudFront (mục 7).

> **Bước tiếp theo**: Chuyển đến [Cấu hình CloudFront để phân phối nội dung](/7-configuring-cloudfront/) để tiếp tục cấu hình!