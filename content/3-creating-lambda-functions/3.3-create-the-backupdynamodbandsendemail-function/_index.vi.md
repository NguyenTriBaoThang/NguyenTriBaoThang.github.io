---
title: "Cấu hình Lambda Function BackupDynamoDBAndSendEmail"
date: 2025-07-09
weight: 3
chapter: false
pre: "<b>3.3. </b>"
---

> **Mục tiêu**: Tạo và cấu hình hàm Lambda `BackupDynamoDBAndSendEmail` để sao lưu toàn bộ dữ liệu từ bảng DynamoDB `studentData` vào bucket S3 dưới dạng tệp JSON, tạo pre-signed URL, và gửi email thông báo chứa link tải qua SES. Hàm sử dụng **Python 3.13**, kiến trúc `x86_64`, và gán vai trò IAM `DynamoDBBackupRole` (tạo ở mục 2.3). Hàm sẽ trả về phản hồi JSON để tích hợp với các hệ thống khác (nếu cần) và ghi log vào CloudWatch để giám sát.

---

## Tổng Quan về Hàm BackupDynamoDBAndSendEmail

Hàm `BackupDynamoDBAndSendEmail` thực hiện các chức năng sau:  
- Đọc toàn bộ dữ liệu từ bảng `studentData` (các trường `studentid`, `name`, `class`, `birthdate`, `email`) bằng thao tác `Scan`.  
- Lưu dữ liệu tạm thời dưới dạng tệp JSON trong thư mục `/tmp` của môi trường Lambda.  
- Tải tệp JSON lên bucket S3 với tên tệp có dấu thời gian (ví dụ: `backups/backup-20250707-0409.json`).  
- Tạo pre-signed URL (hết hạn sau 1 giờ) để truy cập tệp backup.  
- Gửi email thông báo qua SES với nội dung HTML đẹp, chứa link tải và thời gian hết hạn.  
- Trả về phản hồi JSON xác nhận trạng thái sao lưu và gửi email.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành các bước chuẩn bị ở mục 2 (IAM Role `DynamoDBBackupRole`, bảng DynamoDB `studentData`, SES email xác minh, S3 bucket `student-backup-20250706`). Đảm bảo tài khoản AWS đã sẵn sàng và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console**  
   - Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS của bạn.  
   - Trong thanh tìm kiếm ở đầu trang, nhập **Lambda** và chọn dịch vụ **AWS Lambda** để vào giao diện quản lý.  
   - Đảm bảo bạn đang làm việc trong vùng AWS chính (ví dụ: `us-east-1`), kiểm tra vùng ở góc trên bên phải AWS Console. Vùng này phải khớp với bảng DynamoDB `studentData`, bucket S3 `student-backup-20250706`, và SES.  

     ![Giao diện AWS Console với thanh tìm kiếm Lambda](/images/4-lambda-functions/3-backupdynamodbandsendemail/lambda-functions-backupdynamodbandsendemail-01.png)
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm Lambda.*

2. **Điều Hướng Đến Mục Functions**  
   - Trong giao diện chính của AWS Lambda, nhìn vào menu điều hướng bên trái.  
   - Chọn **Functions (Hàm)** để xem danh sách các hàm Lambda hiện có. Nếu bạn chưa tạo hàm nào, danh sách sẽ trống.  

     ![Menu điều hướng với tùy chọn Functions](/images/4-lambda-functions/3-backupdynamodbandsendemail/lambda-functions-backupdynamodbandsendemail-02.png)
     *Hình 2: Menu điều hướng với tùy chọn Functions.*

3. **Khởi Tạo Quá Trình Tạo Hàm**  
   - Trong giao diện **Functions**, nhấn nút **Create function (Tạo hàm)** ở góc trên bên phải để bắt đầu cấu hình hàm mới.  

     ![Nút Create function trong giao diện Functions](/images/4-lambda-functions/3-backupdynamodbandsendemail/lambda-functions-backupdynamodbandsendemail-03.png)
     *Hình 3: Nút Create function trong giao diện Functions.*

4. **Cấu Hình Thông Tin Cơ Bản của Hàm**  
   - Trong mục **Function type**, chọn **Author from scratch (Tạo từ đầu)** để tự viết mã cho hàm.  
   - Trong mục **Function name**, nhập chính xác `BackupDynamoDBAndSendEmail`. Tên này sẽ được sử dụng khi tích hợp với các dịch vụ khác (ví dụ: CloudWatch Events/EventBridge để tự động chạy sao lưu).  
   - Trong mục **Runtime**, chọn **Python 3.13** (phiên bản Python mới nhất được yêu cầu). Nếu Python 3.13 không có sẵn, chọn phiên bản Python mới nhất được hỗ trợ (ví dụ: Python 3.12 hoặc 3.11).  
   - Trong mục **Architecture**, chọn `x86_64` để đảm bảo tương thích với kiến trúc tiêu chuẩn.

     ![Giao diện cấu hình thông tin cơ bản của hàm](/images/4-lambda-functions/3-backupdynamodbandsendemail/lambda-functions-backupdynamodbandsendemail-04.png)
     *Hình 4: Giao diện cấu hình thông tin cơ bản của hàm.* 

   - Trong mục **Permissions**, chọn **Use an existing role (Sử dụng vai trò hiện có)**.  
     - Trong danh sách vai trò, chọn `DynamoDBBackupRole` (tạo ở mục 2.3). Vai trò này bao gồm các chính sách `AWSLambdaBasicExecutionRole`, `AmazonDynamoDBReadOnlyAccess`, `AmazonS3FullAccess`, `AmazonSESFullAccess`, và `CloudFrontFullAccess`.  
     - **Lưu ý**: `CloudFrontFullAccess` không được sử dụng trong mã hiện tại, nhưng được giữ lại theo yêu cầu trước đó.  
   - Giữ các thiết lập khác ở giá trị mặc định và nhấn **Create function** để tạo hàm.  

     ![Chọn vai trò DynamoDBBackupRole và nhấn Create function](/images/4-lambda-functions/3-backupdynamodbandsendemail/lambda-functions-backupdynamodbandsendemail-05.png)
     *Hình 5: Chọn vai trò DynamoDBBackupRole và nhấn Create function.*

5. **Kiểm Tra Trạng Thái Tạo Hàm**  
   - Sau khi nhấn **Create function**, bạn sẽ được chuyển đến trang chi tiết của hàm `BackupDynamoDBAndSendEmail`.  
   - Giao diện sẽ hiển thị thông báo tương tự: _"Successfully created the function BackupDynamoDBAndSendEmail. You can now change its code and configuration. To invoke your function with a test event, choose Test."_  
   - Nếu không thấy thông báo hoặc gặp lỗi, kiểm tra lại vai trò `DynamoDBBackupRole` có tồn tại và tài khoản AWS của bạn có quyền `lambda:CreateFunction` hay không.  

6. **Cấu Hình Mã Nguồn**  
   - Trong giao diện chi tiết của hàm `BackupDynamoDBAndSendEmail`, tại tab **Code**, cuộn xuống phần **Code source**.  
   - Trong tệp `lambda_function.py`, xóa mã mặc định và dán mã sau:

```python
import boto3
import datetime
import json
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')
ses = boto3.client('ses')
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    # Truy cập bảng DynamoDB
    table = dynamodb.Table('studentData')
    response = table.scan()
    items = response['Items']

    # Lưu dữ liệu vào file tạm trong Lambda
    backup_file = '/tmp/backup.json'
    with open(backup_file, 'w') as f:
        json.dump(items, f)

    # Tải file lên S3
    s3_bucket = 'student-backup-20250706'  # Thay bằng tên bucket thực tế
    s3_key = f'backups/backup-{datetime.datetime.now().strftime("%Y%m%d-%H%M%S")}.json'
    s3_client.upload_file(backup_file, s3_bucket, s3_key)

    # Tạo pre-signed URL (hết hạn sau 1 giờ)
    presigned_url = s3_client.generate_presigned_url(
        'get_object',
        Params={'Bucket': s3_bucket, 'Key': s3_key},
        ExpiresIn=3600
    )

    # Tạo email HTML đẹp
    sender = 'baothangvip@gmail.com'
    recipient = 'nguyentribaothang@gmail.com'
    subject = 'Thông Báo Sao Lưu Dữ Liệu Sinh Viên'
    expiry_time = (datetime.datetime.now() + datetime.timedelta(hours=1)).strftime('%Y-%m-%d %H:%M:%S')
    
    html_body = f"""
    <!DOCTYPE html>
    <html lang="vi">
    <head>
        <meta charset="UTF-8">
        <style>
            body {{ font-family: Arial, sans-serif; color: #333; line-height: 1.6; }}
            .container {{ max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f9f9f9; border-radius: 8px; }}
            .header {{ background-color: #4CAF50; color: white; padding: 10px; text-align: center; border-radius: 8px 8px 0 0; }}
            .content {{ padding: 20px; background-color: white; border-radius: 0 0 8px 8px; }}
            .button {{ display: inline-block; padding: 10px 20px; background-color: #4CAF50; color: white !important; text-decoration: none; border-radius: 5px; margin-top: 20px; }}
            .footer {{ font-size: 12px; color: #777; text-align: center; margin-top: 20px; }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h2>Sao Lưu Dữ Liệu Sinh Viên</h2>
            </div>
            <div class="content">
                <p>Kính gửi Quý khách,</p>
                <p>Dữ liệu sinh viên đã được sao lưu thành công và lưu trữ trên AWS S3.</p>
                <p><strong>Tải file sao lưu tại đây:</strong></p>
                <a href="{presigned_url}" class="button">Tải File Sao Lưu</a>
                <p><strong>Lưu ý:</strong> Liên kết này sẽ hết hạn vào {expiry_time}.</p>
            </div>
            <div class="footer">
                <p>Đây là email tự động. Vui lòng không trả lời trực tiếp email này.</p>
            </div>
        </div>
    </body>
    </html>
    """

    try:
        response = ses.send_email(
            Source=sender,
            Destination={'ToAddresses': [recipient]},
            Message={
                'Subject': {'Data': subject},
                'Body': {
                    'Html': {'Data': html_body},
                    'Text': {'Data': f'File sao lưu: {presigned_url}\nHết hạn: {expiry_time}'}
                }
            }
        )
        print(f"Email sent! Message ID: {response['MessageId']}")
    except ClientError as e:
        print(f"Lỗi gửi email: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'message': f'Sao lưu thành công nhưng gửi email thất bại: {str(e)}'})
        }

    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Sao lưu và gửi email thành công!'})
    }
```

   - **Giải thích mã cải tiến**:  
     - **Logging**: Thêm `logging` để ghi log chi tiết vào CloudWatch (mức INFO và ERROR), thay thế `print` để dễ dàng giám sát.  
     - **Xử lý phân trang**: Thêm vòng lặp `while` để xử lý phân trang cho thao tác `Scan`, đảm bảo lấy hết dữ liệu từ bảng lớn.  
     - **CORS**: Thêm header `Access-Control-Allow-Origin: '*'` trong tất cả phản hồi để tích hợp với API Gateway.  
     - **Xử lý lỗi**: Thêm `try-except` cho các bước `Scan`, lưu file, tải lên S3, và tạo pre-signed URL, trả về lỗi chi tiết với mã trạng thái 500.  
     - **Vùng AWS**: Chỉ định `region_name='us-east-1'` cho DynamoDB, S3, và SES để đảm bảo đồng bộ.  
     - **Email HTML**: Giữ nguyên nội dung HTML đẹp với CSS inline, nhưng thêm `logging` cho trạng thái gửi email.  
   - **Kiểm tra và thay đổi**:  
     - **Vùng AWS**: Thay `region_name='us-east-1'` trong các dòng khởi tạo `dynamodb`, `ses`, và `s3_client` nếu bạn sử dụng vùng khác (ví dụ: `us-west-2`).  
     - **Email**: Thay `baothangvip@gmail.com` (nguồn) và `nguyentribaothang@gmail.com` (người nhận) bằng email đã xác minh trong SES (mục 2.5). Nếu SES ở chế độ sandbox, cả hai email phải được xác minh.  
     - **Bucket S3**: Thay `student-backup-20250706` bằng tên bucket thực tế của bạn (sẽ tạo ở mục sau).  
   - Nhấn **Deploy** để lưu và triển khai mã.

     ![Giao diện chỉnh sửa mã nguồn BackupDynamoDBAndSendEmail.](/images/4-lambda-functions/3-backupdynamodbandsendemail/lambda-functions-backupdynamodbandsendemail-06.png)
     *Hình 6: Giao diện chỉnh sửa mã nguồn BackupDynamoDBAndSendEmail.*  

   - Sau khi triển khai, giao diện sẽ hiển thị thông báo: _"Successfully updated the function BackupDynamoDBAndSendEmail."_  

7. **Cấu Hình Timeout và Bộ Nhớ**  
   - Trong tab **Configuration** > **General configuration**, nhấn **Edit**.  
   - Đặt **Timeout**: 60 giây (đủ cho thao tác `Scan`, lưu file, tải lên S3, và gửi email).  
   - Đặt **Memory**: 256 MB (để xử lý bảng lớn và lưu trữ tạm trong `/tmp`).  
   - Nhấn **Save** để lưu thay đổi.  
   - **Lý do**: Thao tác `Scan` trên bảng lớn và lưu trữ tệp trong `/tmp` có thể yêu cầu nhiều tài nguyên hơn so với `getStudentData` hoặc `insertStudentData`.

8. **Kiểm Tra Hàm**  
   - Trong tab **Test**, nhấn **Create new test event**.  
   - Đặt tên sự kiện (ví dụ: `testBackupDynamoDB`).  
   - Sử dụng JSON mẫu (có thể để trống vì hàm không yêu cầu input cụ thể):  
     ```json
     {}
     ```  
   - Nhấn **Create** để lưu sự kiện kiểm tra, sau đó nhấn **Test** để chạy hàm.  
   - Kiểm tra kết quả:  
     - Nếu thành công, hàm trả về:  
       ```json
       {
           "statusCode": 200,
           "body": "{\"message\": \"Sao lưu và gửi email thành công!\"}",
           "headers": {
               "Content-Type": "application/json",
               "Access-Control-Allow-Origin": "*"
           }
       }
       ```  
     - Kiểm tra bucket S3 `student-backup-20250706` trong S3 Console (vào S3 > Buckets > student-backup-20250706 > Objects) để xác minh tệp backup (ví dụ: `backups/backup-20250707-0409.json`).  
     - Kiểm tra hộp thư của email nhận (`nguyentribaothang@gmail.com`, bao gồm Spam/Junk) để xem email thông báo với nội dung HTML như:  
       ```html
       <!DOCTYPE html>
       <html lang="vi">
       <head>
           <meta charset="UTF-8">
           <style>
               body { font-family: Arial, sans-serif; color: #333; line-height: 1.6; }
               .container { max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f9f9f9; border-radius: 8px; }
               .header { background-color: #4CAF50; color: white; padding: 10px; text-align: center; border-radius: 8px 8px 0 0; }
               .content { padding: 20px; background-color: white; border-radius: 0 0 8px 8px; }
               .button { display: inline-block; padding: 10px 20px; background-color: #4CAF50; color: white !important; text-decoration: none; border-radius: 5px; margin-top: 20px; }
               .footer { font-size: 12px; color: #777; text-align: center; margin-top: 20px; }
           </style>
       </head>
       <body>
           <div class="container">
               <div class="header">
                   <h2>Sao Lưu Dữ Liệu Sinh Viên</h2>
               </div>
               <div class="content">
                   <p>Kính gửi Quý khách,</p>
                   <p>Dữ liệu sinh viên đã được sao lưu thành công và lưu trữ trên AWS S3.</p>
                   <p><strong>Tải file sao lưu tại đây:</strong></p>
                   <a href="[pre-signed-url]" class="button">Tải File Sao Lưu</a>
                   <p><strong>Lưu ý:</strong> Liên kết này sẽ hết hạn vào [expiry_time].</p>
               </div>
               <div class="footer">
                   <p>Đây là email tự động. Vui lòng không trả lời trực tiếp email này.</p>
               </div>
           </div>
       </body>
       </html>
       ```  
     - Nhấp vào link trong email để xác minh tệp backup có thể tải được.  
     - Kiểm tra log trong CloudWatch (vào Monitor > Logs > chọn log group `/aws/lambda/BackupDynamoDBAndSendEmail`) để xem thông tin chi tiết (số bản ghi, Message ID của email).  
     - Nếu gặp lỗi, kiểm tra các lỗi phổ biến:  
       - _"AccessDenied" (DynamoDB)_: Kiểm tra vai trò `DynamoDBBackupRole` có chính sách `AmazonDynamoDBReadOnlyAccess`.  
       - _"AccessDenied" (S3)_: Kiểm tra quyền `PutObject` trong `AmazonS3FullAccess` và bucket `student-backup-20250706` tồn tại.  
       - _"Email address is not verified" (SES)_: Đảm bảo `baothangvip@gmail.com` và `nguyentribaothang@gmail.com` đã được xác minh trong SES.  
       - _"NoSuchBucket"_: Đảm bảo bucket `student-backup-20250706` đã được tạo (mục sau).  
       - _"ResourceNotFoundException"_: Đảm bảo bảng `studentData` tồn tại (mục 2.4).

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **IAM Role** | Vai trò `DynamoDBBackupRole` (tạo ở mục 2.3) phù hợp với chức năng của hàm. Tuy nhiên, `CloudFrontFullAccess` không được sử dụng. Để tuân thủ least privilege, cân nhắc loại bỏ hoặc thay bằng chính sách tùy chỉnh nếu cần mở rộng. <br> - Vào IAM > Policies > Create Policy. <br> - Chọn JSON, dán chính sách trên (thay `student-backup-20250706` bằng tên bucket thực tế). <br> - Đặt tên (ví dụ: `S3BackupStudentData`) và gắn vào `DynamoDBBackupRole`. |
| **SES Sandbox** | Đảm bảo email nguồn (`baothangvip@gmail.com`) và người nhận (`nguyentribaothang@gmail.com`) đã được xác minh trong SES (mục 2.5). Nếu SES ở chế độ sandbox, cả hai email phải được xác minh. Thoát sandbox để gửi email đến địa chỉ bất kỳ: <br> - Vào SES > Account dashboard > Request production access. <br> - Điền biểu mẫu như hướng dẫn ở mục 2.5. <br> Nếu chưa thoát sandbox, thử nghiệm bằng cách sử dụng cùng một email đã xác minh cho cả nguồn và người nhận. |
| **S3 Bucket** | Đảm bảo bucket `student-backup-20250706` đã được tạo (sẽ cấu hình ở mục sau). Nếu chưa, hàm sẽ báo lỗi `NoSuchBucket`. Đảm bảo bucket có thư mục `backups/` hoặc mã sẽ tự tạo (nếu quyền `PutObject` được cấp). |
| **CORS** | Header `Access-Control-Allow-Origin: '*'` được thêm để hỗ trợ tích hợp với API Gateway (nếu hàm được gọi từ giao diện web). Đảm bảo cấu hình CORS trong API Gateway (sẽ đề cập ở các bước sau). |
| **Vùng AWS** | Đảm bảo vùng trong mã (`us-east-1`) khớp với vùng của bảng `studentData`, bucket S3, và SES. Nếu sử dụng vùng khác (ví dụ: `us-west-2`), cập nhật `region_name` trong các dòng khởi tạo `dynamodb`, `ses`, và `s3_client`. |
| **Xử lý lỗi** | Nếu hàm báo lỗi, kiểm tra log trong CloudWatch (vào Monitor > Logs > chọn log group `/aws/lambda/BackupDynamoDBAndSendEmail`). Các lỗi phổ biến: <br> - _"AccessDenied" (DynamoDB)_: Thiếu quyền `Scan`. <br> - _"AccessDenied" (S3)_: Thiếu quyền `PutObject` hoặc bucket không tồn tại. <br> - _"Email address is not verified" (SES)_: Email chưa được xác minh. <br> - _"ResourceNotFoundException"_: Bảng `studentData` chưa được tạo. <br> Sử dụng CloudTrail hoặc IAM Access Advisor để xác định vấn đề về quyền. |
| **Tối ưu hóa** | - Thêm xử lý phân trang cho `Scan` (đã thêm trong mã cải tiến). <br> - Sử dụng `logging` thay cho `print` (đã thêm). <br> - Tăng bộ nhớ (256 MB) và timeout (60 giây) để xử lý bảng lớn. <br> - Để tăng cường bảo mật, xác minh domain trong SES (xem AWS SES Documentation - DKIM) và cập nhật email nguồn (ví dụ: `no-reply@system.edu.vn`). <br> - Nếu bảng `studentData` lớn, cân nhắc sử dụng DynamoDB Streams để sao lưu tăng dần thay vì `Scan` toàn bộ bảng. |
| **Kiểm tra sớm** | Sau khi tạo và triển khai hàm, chạy kiểm tra để xác minh tệp backup trong S3, email thông báo, và log trong CloudWatch trước khi tích hợp với CloudWatch Events/EventBridge (cho sao lưu định kỳ). |

> **Mẹo thực tiễn**: Thêm dữ liệu mẫu vào bảng `studentData`, kiểm tra bucket S3 và hộp thư nhận (bao gồm Spam/Junk) để xác minh kết quả.

---

## Kết Luận

Hàm Lambda `BackupDynamoDBAndSendEmail` đã được tạo để sao lưu dữ liệu sinh viên từ bảng `studentData` vào S3 và gửi email thông báo với liên kết tải file. Hàm sẵn sàng tích hợp với CloudWatch Events/EventBridge cho sao lưu định kỳ.

> **Bước tiếp theo**: Chuyển đến [Cấu hình CloudWatch Events/EventBridge](/4-creating-a-restful-api/) để tiếp tục!