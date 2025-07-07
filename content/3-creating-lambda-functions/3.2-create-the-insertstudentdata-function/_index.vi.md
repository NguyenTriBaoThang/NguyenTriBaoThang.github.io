---
title: "Cấu hình Lambda Function insertStudentData"
date: 2023-10-25
weight: 2
chapter: false
pre: "<b>3.2 </b>"
---

> **Mục tiêu**: Tạo và cấu hình hàm Lambda `insertStudentData` để nhận thông tin sinh viên từ giao diện web, lưu vào bảng DynamoDB `studentData`, và gửi email xác nhận qua SES. Hàm này xử lý dữ liệu các trường Mã sinh viên (`studentid`), Họ tên (`name`), Lớp (`class`), Ngày sinh (`birthdate`), và Email (`email`), đồng thời kiểm tra tính hợp lệ và trùng lặp trước khi lưu. Hàm sử dụng **Python 3.13**, kiến trúc `x86_64`, và gán vai trò IAM `LambdaInsertStudentRole` (sửa lỗi từ `LambdaGetStudentRole` trong yêu cầu). Hàm sẽ trả về phản hồi JSON để tích hợp với giao diện web qua API Gateway.

---

## Tổng Quan về Hàm insertStudentData

Hàm `insertStudentData` thực hiện các chức năng sau:  
- Nhận dữ liệu từ `event['body']` (gửi từ giao diện web qua API Gateway).  
- Kiểm tra dữ liệu đầu vào (đảm bảo tất cả các trường bắt buộc được cung cấp).  
- Kiểm tra trùng `studentid` bằng thao tác `GetItem` để tránh lưu dữ liệu trùng lặp.  
- Lưu dữ liệu vào bảng `studentData` bằng thao tác `PutItem`.  
- Gửi email xác nhận qua SES với nội dung chi tiết (mã sinh viên, họ tên, lớp, ngày sinh).  
- Ghi log chi tiết vào CloudWatch để giám sát và gỡ lỗi.  
- Trả về phản hồi JSON với header CORS (`Access-Control-Allow-Origin: '*'`) để hỗ trợ giao diện web.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành các bước chuẩn bị ở mục 2 (IAM Role `LambdaInsertStudentRole`, bảng DynamoDB `studentData`, SES email xác minh) trước khi tạo hàm. Đảm bảo tài khoản AWS đã sẵn sàng và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console**  
   - Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS của bạn.  
   - Trong thanh tìm kiếm ở đầu trang, nhập **Lambda** và chọn dịch vụ **AWS Lambda** để vào giao diện quản lý.  
   - Đảm bảo bạn đang làm việc trong vùng AWS chính (ví dụ: `us-east-1`), kiểm tra vùng ở góc trên bên phải AWS Console. Vùng này phải khớp với bảng DynamoDB `studentData` và SES.  

     ![Giao diện AWS Console với thanh tìm kiếm Lambda](/images/4-lambda-functions/2-insertstudentdata/lambda-functions-insertstudentdata-01.png)
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm Lambda.*

2. **Điều Hướng Đến Mục Functions**  
   - Trong giao diện chính của AWS Lambda, nhìn vào menu điều hướng bên trái.  
   - Chọn **Functions (Hàm)** để xem danh sách các hàm Lambda hiện có. Nếu bạn chưa tạo hàm nào, danh sách sẽ trống.  

     ![Menu điều hướng với tùy chọn Functions](/images/4-lambda-functions/2-insertstudentdata/lambda-functions-insertstudentdata-02.png)  
     *Hình 2: Menu điều hướng với tùy chọn Functions.*

3. **Khởi Tạo Quá Trình Tạo Hàm**  
   - Trong giao diện **Functions**, nhấn nút **Create function (Tạo hàm)** ở góc trên bên phải để bắt đầu cấu hình hàm mới.  

     ![Nút Create function trong giao diện Functions](/images/4-lambda-functions/2-insertstudentdata/lambda-functions-insertstudentdata-03.png)
     *Hình 3: Nút Create function trong giao diện Functions.*

4. **Cấu Hình Thông Tin Cơ Bản của Hàm**  
   - Trong mục **Function type**, chọn **Author from scratch (Tạo từ đầu)** để tự viết mã cho hàm.  
   - Trong mục **Function name**, nhập chính xác `insertStudentData`. Tên này sẽ được sử dụng khi tích hợp với API Gateway.  
   - Trong mục **Runtime**, chọn **Python 3.13** (phiên bản Python mới nhất được yêu cầu). Nếu Python 3.13 không có sẵn, chọn phiên bản Python mới nhất được hỗ trợ (ví dụ: Python 3.12 hoặc 3.11).  
   - Trong mục **Architecture**, chọn `x86_64` để đảm bảo tương thích với kiến trúc tiêu chuẩn.  

    ![Giao diện cấu hình thông tin cơ bản của hàm](/images/4-lambda-functions/2-insertstudentdata/lambda-functions-insertstudentdata-04.png)  
     *Hình 4: Giao diện cấu hình thông tin cơ bản của hàm.*  

   - Trong mục **Permissions**, chọn **Use an existing role (Sử dụng vai trò hiện có)**.  
     - Trong danh sách vai trò, chọn `LambdaInsertStudentRole` (đã tạo ở mục 2.2).  
     - **Lưu ý quan trọng**: Yêu cầu ban đầu chỉ định `LambdaGetStudentRole`, nhưng vai trò này không phù hợp vì thiếu quyền `dynamodb:PutItem` và `ses:SendEmail`. Vai trò `LambdaInsertStudentRole` bao gồm `AWSLambdaBasicExecutionRole`, `AmazonDynamoDBReadOnlyAccess`, `AmazonSESFullAccess`, `AmazonS3FullAccess`, và `CloudFrontFullAccess`, nhưng `AmazonDynamoDBReadOnlyAccess` không hỗ trợ `PutItem`. Cần thay bằng `AmazonDynamoDBFullAccess` hoặc chính sách tùy chỉnh (xem Lưu ý).  
   - Giữ các thiết lập khác ở giá trị mặc định và nhấn **Create function** để tạo hàm.  

     ![Chọn vai trò LambdaInsertStudentRole và nhấn Create function](/images/4-lambda-functions/2-insertstudentdata/lambda-functions-insertstudentdata-05.png)  
     *Hình 5: Chọn vai trò LambdaInsertStudentRole và nhấn Create function.*

5. **Kiểm Tra Trạng Thái Tạo Hàm**  
   - Sau khi nhấn **Create function**, bạn sẽ được chuyển đến trang chi tiết của hàm `insertStudentData`.  
   - Giao diện sẽ hiển thị thông báo tương tự: _"Successfully created the function insertStudentData. You can now change its code and configuration. To invoke your function with a test event, choose Test."_  
   - Nếu không thấy thông báo hoặc gặp lỗi, kiểm tra lại vai trò `LambdaInsertStudentRole` có tồn tại và tài khoản AWS của bạn có quyền `lambda:CreateFunction` hay không.  

     ![Trang chi tiết của hàm insertStudentData sau khi tạo](/images/4-lambda-functions/2-insertstudentdata/lambda-functions-insertstudentdata-06.png)  
     *Hình 6: Trang chi tiết của hàm insertStudentData sau khi tạo.*

6. **Cấu Hình Mã Nguồn**  
   - Trong giao diện chi tiết của hàm `insertStudentData`, tại tab **Code**, cuộn xuống phần **Code source**.  
   - Trong tệp `lambda_function.py`, xóa mã mặc định và dán mã sau:

```python
import json
import boto3
import logging

# Thiết lập logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Khởi tạo kết nối DynamoDB và SES
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('studentData')
ses = boto3.client('ses', region_name='us-east-1')

def lambda_handler(event, context):
    logger.info("Event nhận được: %s", json.dumps(event))

    # Xử lý request body
    try:
        if isinstance(event.get('body'), str):
            body = json.loads(event['body'])
        elif isinstance(event.get('body'), dict):
            body = event['body']
        else:
            body = {}
    except Exception as e:
        logger.error("Lỗi khi parse JSON: %s", str(e))
        return _response(400, "Dữ liệu gửi lên không hợp lệ.")

    # Lấy các trường
    student_id = body.get('studentid')
    name = body.get('name')
    student_class = body.get('class')
    birthdate = body.get('birthdate')
    email = body.get('email')

    # Kiểm tra dữ liệu hợp lệ
    if not all([student_id, name, student_class, birthdate, email]):
        logger.error("Thiếu các trường: studentid=%s, name=%s, class=%s, birthdate=%s, email=%s",
                     student_id, name, student_class, birthdate, email)
        return _response(400, "Thiếu thông tin sinh viên cần thiết.")

    # Kiểm tra trùng mã sinh viên
    try:
        existing = table.get_item(Key={'studentid': student_id})
        if 'Item' in existing:
            logger.error("Mã sinh viên %s đã tồn tại", student_id)
            return _response(409, f"Mã sinh viên '{student_id}' đã tồn tại.")
    except Exception as e:
        logger.error("Lỗi khi kiểm tra mã sinh viên: %s", str(e))
        return _response(500, "Lỗi khi kiểm tra dữ liệu.")

    # Lưu dữ liệu vào DynamoDB
    try:
        table.put_item(
            Item={
                'studentid': student_id,
                'name': name,
                'class': student_class,
                'birthdate': birthdate,
                'email': email
            }
        )
        logger.info("Lưu dữ liệu thành công cho studentid: %s", student_id)
    except Exception as e:
        logger.error("Lỗi khi lưu vào DynamoDB: %s", str(e))
        return _response(500, "Lỗi khi lưu dữ liệu vào hệ thống.")

    # Gửi email thông báo
    email_error = None
    try:
        ses.send_email(
            Source='baothangvip@gmail.com',
            Destination={'ToAddresses': [email]},
            Message={
                'Subject': {'Data': 'Dữ Liệu Sinh Viên Đã Được Lưu'},
                'Body': {
                    'Text': {
                        'Data': (
                            f'📢 THÔNG BÁO TỪ HỆ THỐNG QUẢN LÝ SINH VIÊN HUTECH\n\n'
                            f'Chào bạn {name},\n\n'
                            f'✅ Thông tin sinh viên của bạn đã được lưu thành công trên hệ thống.\n\n'
                            f'🔹 Mã sinh viên: {student_id}\n'
                            f'🔹 Họ tên: {name}\n'
                            f'🔹 Lớp: {student_class}\n'
                            f'🔹 Ngày sinh: {birthdate}\n\n'
                            f'📬 Vui lòng giữ email này để đối chiếu khi cần thiết.\n\n'
                            f'Thân mến,\n'
                            f'📘 Hệ thống quản lý sinh viên\n'
                            f'📧 Email: hutech@system.edu.vn (nếu bạn muốn dùng tên miền riêng)\n'
                        )
                    }
                }
            }
        )
        logger.info("Gửi email thành công tới: %s", email)
    except Exception as e:
        email_error = str(e)
        logger.error("Lỗi khi gửi email tới %s: %s", email, email_error)

    # Trả kết quả
    if email_error:
        return _response(200, f"Dữ liệu sinh viên đã được lưu nhưng gửi email tới {email} thất bại: {email_error}")
    return _response(200, "Dữ liệu sinh viên đã được lưu và email thông báo đã được gửi!")

# Hàm trả về response chuẩn
def _response(status_code, message):
    return {
        'statusCode': status_code,
        'body': json.dumps({'message': message}),
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        }
    }
```

   - **Giải thích mã**:  
     - **Logging**: Sử dụng `logging` để ghi log chi tiết vào CloudWatch (mức INFO và ERROR), hỗ trợ giám sát và gỡ lỗi.  
     - **Xử lý đầu vào**: Kiểm tra `event['body']` là chuỗi JSON hoặc dict, xử lý lỗi parse JSON.  
     - **Kiểm tra dữ liệu**: Đảm bảo tất cả các trường `studentid`, `name`, `class`, `birthdate`, `email` được cung cấp.  
     - **Kiểm tra trùng lặp**: Sử dụng `GetItem` để kiểm tra `studentid` đã tồn tại trong bảng `studentData`.  
     - **Lưu dữ liệu**: Thao tác `PutItem` lưu dữ liệu sinh viên vào bảng `studentData`.  
     - **Gửi email**: Gửi email xác nhận qua SES với nội dung chi tiết, sử dụng `baothangvip@gmail.com` làm nguồn (phải được xác minh trong SES).  
     - **Phản hồi**: Trả về JSON với mã trạng thái (200, 400, 409, 500) và header CORS để tích hợp với giao diện web.  
   - **Kiểm tra và thay đổi**:  
     - **Vùng AWS**: Thay `region_name='us-east-1'` trong dòng `ses = boto3.client('ses', region_name='us-east-1')` nếu bạn sử dụng vùng khác (ví dụ: `us-west-2`). Lưu ý rằng `dynamodb = boto3.resource('dynamodb')` không chỉ định vùng để linh hoạt hơn, nhưng bạn nên thêm `region_name='us-east-1'` cho đồng bộ:  
       ```python
       dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
       ```  
     - **Email nguồn**: Thay `baothangvip@gmail.com` bằng email đã xác minh trong SES (mục 2.5). Nếu chưa xác minh, hàm sẽ báo lỗi "Email address is not verified".  
   - Nhấn **Deploy** để lưu và triển khai mã.  
   
     ![Giao diện chỉnh sửa mã nguồn insertStudentData](/images/4-lambda-functions/2-insertstudentdata/lambda-functions-insertstudentdata-07.png)
     *Hình 7: Giao diện chỉnh sửa mã nguồn insertStudentData.*  
   - Sau khi triển khai, giao diện sẽ hiển thị thông báo: _"Successfully updated the function insertStudentData."_  
 
     ![Thông báo triển khai thành công](/images/4-lambda-functions/2-insertstudentdata/lambda-functions-insertstudentdata-08.png)
     *Hình 8: Thông báo triển khai thành công.*

7. **Cấu Hình Timeout và Bộ Nhớ**  
   - Trong tab **Configuration** > **General configuration**, nhấn **Edit**.  
   - Đặt **Timeout**: 30 giây (đủ cho thao tác `PutItem`, `GetItem`, và gửi email qua SES).  
   - Đặt **Memory**: 128 MB (mặc định, đủ cho hàm này vì các thao tác đơn giản).  
   - Nhấn **Save** để lưu thay đổi.

8. **Kiểm Tra Hàm**  
   - Trong tab **Test**, nhấn **Create new test event**.  
   - Đặt tên sự kiện (ví dụ: `testInsertStudentData`).  
   - Sử dụng JSON mẫu:  
     ```json
     {
         "body": "{\"studentid\": \"SV001\", \"name\": \"Nguyen Van A\", \"class\": \"CNTT01\", \"birthdate\": \"2000-01-01\", \"email\": \"baothangvip@gmail.com\"}"
     }
     ```  
   - Nhấn **Create** để lưu sự kiện kiểm tra, sau đó nhấn **Test** để chạy hàm.  
   - Kiểm tra kết quả:  
     - Nếu thành công, hàm trả về:  
       ```json
       {
           "statusCode": 200,
           "body": "{\"message\": \"Dữ liệu sinh viên đã được lưu và email thông báo đã được gửi!\"}",
           "headers": {
               "Content-Type": "application/json",
               "Access-Control-Allow-Origin": "*"
           }
       }
       ```  
     - Kiểm tra bảng `studentData` trong DynamoDB Console để xác minh dữ liệu đã được lưu (vào DynamoDB > Tables > studentData > Explore items).  
     - Kiểm tra hộp thư của email nhận (`baothangvip@gmail.com`, bao gồm Spam/Junk) để xem email xác nhận.  
     - Nếu gặp lỗi, kiểm tra log trong CloudWatch (vào Monitor > Logs > chọn log group `/aws/lambda/insertStudentData`). Các lỗi phổ biến:  
       - _"AccessDenied" (DynamoDB)_: Vai trò `LambdaInsertStudentRole` thiếu quyền `PutItem`. Thay `AmazonDynamoDBReadOnlyAccess` bằng chính sách tùy chỉnh hoặc `AmazonDynamoDBFullAccess`.  
       - _"Email address is not verified" (SES)_: Đảm bảo email `baothangvip@gmail.com` đã được xác minh trong SES (mục 2.5). Nếu SES ở chế độ sandbox, email nhận cũng phải được xác minh.  
       - _"ResourceNotFoundException"_: Đảm bảo bảng `studentData` đã được tạo (mục 2.4).  
       - _"Invalid JSON"_: Kiểm tra JSON trong sự kiện kiểm tra có đúng định dạng không.

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **Sửa lỗi vai trò IAM** | Yêu cầu ban đầu sử dụng `LambdaGetStudentRole`, nhưng vai trò này không phù hợp vì thiếu quyền `dynamodb:PutItem` và `ses:SendEmail`. Sử dụng `LambdaInsertStudentRole` (tạo ở mục 2.2) là đúng. Nếu bạn cố ý muốn dùng `LambdaGetStudentRole`, cần thêm các chính sách `AmazonDynamoDBFullAccess` và `AmazonSESFullAccess` vào vai trò này trong IAM Console: <br> - Vào IAM > Roles > LambdaGetStudentRole > Add permissions > Attach policies. <br> - Tìm và chọn `AmazonDynamoDBFullAccess` và `AmazonSESFullAccess`. <br> Tuy nhiên, để tránh nhầm lẫn, nên sử dụng `LambdaInsertStudentRole` như hướng dẫn. |
| **DynamoDB quyền** | Chính sách `AmazonDynamoDBReadOnlyAccess` trong `LambdaInsertStudentRole` không hỗ trợ `PutItem`. Cần thay bằng `AmazonDynamoDBFullAccess` hoặc chính sách tùy chỉnh như sau: <br> - Vào IAM > Policies > Create Policy. <br> - Chọn JSON, dán chính sách tùy chỉnh (thay `your-account-id` bằng ID tài khoản AWS). <br> - Đặt tên (ví dụ: `DynamoDBPutItemStudentData`) và gắn vào `LambdaInsertStudentRole`. |
| **SES Sandbox** | Đảm bảo email nguồn (`baothangvip@gmail.com`) đã được xác minh trong SES (mục 2.5). Nếu SES ở chế độ sandbox, email nhận (`body['email']`) cũng phải được xác minh. Thoát sandbox để gửi email đến địa chỉ bất kỳ. |
| **Bảng DynamoDB** | Bảng `studentData` phải tồn tại với `studentid` (Partition Key, String), `name`, `class`, `birthdate`, `email`. Hoàn thành mục 2.4 trước. |
| **CORS** | Header `Access-Control-Allow-Origin: '*'` cần cho giao diện web (CloudFront) gọi qua API Gateway. Cấu hình CORS trong API Gateway sau. |
| **Vùng AWS** | Đảm bảo `region_name='us-east-1'` trong mã khớp với vùng của bảng `studentData` và SES. Cập nhật nếu dùng vùng khác (ví dụ: `us-west-2`). |
| **Xử lý lỗi** | Kiểm tra log trong CloudWatch (`/aws/lambda/insertStudentData`) nếu lỗi. Dùng CloudTrail hoặc IAM Access Advisor để xác định vấn đề quyền. |
| **Tối ưu hóa** | Thao tác `PutItem` và `GetItem` hiệu quả hơn `Scan`. Thêm dữ liệu mẫu vào `studentData` để thử nghiệm. |
| **Kiểm tra sớm** | Chạy kiểm tra để xác minh dữ liệu lưu đúng và email được gửi trước khi tích hợp với API Gateway. |

> **Mẹo thực tiễn**: Thêm dữ liệu mẫu vào bảng `studentData`, kiểm tra log CloudWatch, và xác minh email nhận để gỡ lỗi trước khi tích hợp.

---

## Kết Luận

Hàm Lambda `insertStudentData` đã được tạo để nhận và lưu dữ liệu sinh viên vào bảng `studentData`, đồng thời gửi email xác nhận qua SES. Hàm sẵn sàng tích hợp với API Gateway.

> **Bước tiếp theo**: Chuyển đến [Tạo hàm BackupDynamoDBAndSendEmail](/3-creating-lambda-functions/3.3-create-the-backupdynamodbandsendemail-function/) để tiếp tục!