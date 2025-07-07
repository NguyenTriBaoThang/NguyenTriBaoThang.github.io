---
title: "Cấu hình Lambda Function getStudentData"
date: 2023-10-25
weight: 1
chapter: false
pre: "<b>3.1 </b>"
---

> **Mục tiêu**: Tạo và cấu hình hàm Lambda `getStudentData` để truy xuất toàn bộ dữ liệu sinh viên từ bảng DynamoDB `studentData`, bao gồm các trường Mã sinh viên (`studentid`), Họ tên (`name`), Lớp (`class`), Ngày sinh (`birthdate`), và Email (`email`). Hàm này sử dụng thao tác Scan để lấy dữ liệu và trả về kết quả dưới dạng JSON, hỗ trợ tích hợp với giao diện web thông qua API Gateway.

Hàm sử dụng **Python 3.13**, kiến trúc `x86_64`, gán vai trò IAM `LambdaGetStudentRole` (tạo ở mục 2.1), và tích hợp với DynamoDB.

---

## Yêu Cầu Ban Đầu

{{% notice info %}}
Bạn cần hoàn thành các bước chuẩn bị ở mục 2 (IAM Role `LambdaGetStudentRole`, bảng DynamoDB `studentData`) trước khi tạo hàm. Đảm bảo tài khoản AWS đã sẵn sàng và vùng AWS là `us-east-1`.
{{% /notice %}}

---

## Tổng Quan về Hàm getStudentData

Hàm `getStudentData` thực hiện các chức năng sau:  
- Kết nối tới bảng DynamoDB `studentData` trong vùng AWS (mặc định `us-east-1`).  
- Thực hiện thao tác **Scan** để lấy toàn bộ dữ liệu sinh viên, xử lý phân trang nếu bảng lớn.  
- Trả về dữ liệu dưới dạng JSON với header CORS (`Access-Control-Allow-Origin: '*'`) để giao diện web (chạy trên CloudFront) có thể truy cập thông qua API Gateway.  
- Ghi log vào CloudWatch để giám sát và gỡ lỗi (hỗ trợ bởi chính sách `AWSLambdaBasicExecutionRole`).

---

## Hành Động Chi Tiết

1. **Truy Cập AWS Management Console**  
   - Mở trình duyệt và đăng nhập vào **[AWS Management Console](https://console.aws.amazon.com)** bằng tài khoản AWS.  
   - Trong thanh tìm kiếm ở đầu trang, nhập **Lambda** và chọn **AWS Lambda** để vào giao diện quản lý.  
   - Đảm bảo vùng AWS là `us-east-1` (khớp với bảng `studentData`), kiểm tra ở góc trên bên phải AWS Console.  

     ![Giao diện AWS Console với thanh tìm kiếm Lambd](/images/4-lambda-functions/1-getstudentdata/lambda-functions-getstudentdata-01.png)
     *Hình 1: Giao diện AWS Console với thanh tìm kiếm Lambda.*

2. **Điều Hướng Đến Mục Functions**  
   - Trong giao diện chính của AWS Lambda, nhìn vào menu điều hướng bên trái.  
   - Chọn **Functions (Hàm)** để xem danh sách các hàm Lambda hiện có. Nếu chưa tạo hàm nào, danh sách sẽ trống.  

     ![Menu điều hướng với tùy chọn Functions](/images/4-lambda-functions/1-getstudentdata/lambda-functions-getstudentdata-02.png)
     *Hình 2: Menu điều hướng với tùy chọn Functions.*

3. **Khởi Tạo Quá Trình Tạo Hàm**  
   - Trong giao diện **Functions**, nhấn nút **Create function (Tạo hàm)** ở góc trên bên phải để bắt đầu cấu hình hàm mới.  

     ![Nút Create function trong giao diện Functions](/images/4-lambda-functions/1-getstudentdata/lambda-functions-getstudentdata-03.png)
     *Hình 3: Nút Create function trong giao diện Functions.*

4. **Cấu Hình Thông Tin Cơ Bản của Hàm**  
   - Trong mục **Function type**, chọn **Author from scratch (Tạo từ đầu)**.  
   - Trong mục **Function name**, nhập chính xác `getStudentData`.  
   - Trong mục **Runtime**, chọn **Python 3.13**. Nếu không có Python 3.13, chọn phiên bản mới nhất (ví dụ: Python 3.12 hoặc 3.11).  
   - Trong mục **Architecture**, chọn `x86_64`.  

     ![Giao diện cấu hình thông tin cơ bản của hàm](/images/4-lambda-functions/1-getstudentdata/lambda-functions-getstudentdata-04.png)
     *Hình 4: Giao diện cấu hình thông tin cơ bản của hàm.*  

   - Trong mục **Permissions**, chọn **Use an existing role (Sử dụng vai trò hiện có)**, chọn `LambdaGetStudentRole` (tạo ở mục 2.1, bao gồm `AWSLambdaBasicExecutionRole`, `AmazonDynamoDBReadOnlyAccess`, `AmazonS3FullAccess`, `CloudFrontFullAccess`).  
   - Lưu ý: `AmazonS3FullAccess` và `CloudFrontFullAccess` không được sử dụng trong mã hiện tại, nhưng được giữ lại theo yêu cầu trước đó.  
   - Giữ các thiết lập khác mặc định và nhấn **Create function**.  

     ![Tạo Use an exsting role và Create funciton](/images/4-lambda-functions/1-getstudentdata/lambda-functions-getstudentdata-05.png)
     *Hình 5: Chọn vai trò LambdaGetStudentRole và nhấn Create function.*

5. **Kiểm Tra Trạng Thái Tạo Hàm**  
   - Sau khi nhấn **Create function**, bạn sẽ được chuyển đến trang chi tiết của hàm `getStudentData`.  
   - Giao diện hiển thị thông báo tương tự: _"Successfully created the function getStudentData. You can now change its code and configuration. To invoke your function with a test event, choose Test."_  
   - Nếu không thấy thông báo hoặc gặp lỗi, kiểm tra `LambdaGetStudentRole` có tồn tại và tài khoản AWS có quyền `lambda:CreateFunction`.  

     ![Trang chi tiết của hàm getStudentData sau khi tạo](/images/4-lambda-functions/1-getstudentdata/lambda-functions-getstudentdata-06.png)
     *Hình 6: Trang chi tiết của hàm getStudentData sau khi tạo.*

6. **Cấu Hình Mã Nguồn**  
   - Trong tab **Code**, cuộn xuống phần **Code source**.  
   - Trong tệp `lambda_function.py`, xóa mã mặc định và dán mã sau:

```python
import json
import boto3

def lambda_handler(event, context):
    # Kết nối tới DynamoDB trong vùng us-east-1
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    table = dynamodb.Table('studentData')

    # Lấy toàn bộ dữ liệu từ bảng studentData
    response = table.scan()
    data = response['Items']

    # Tiếp tục quét nếu còn dữ liệu (phân trang)
    while 'LastEvaluatedKey' in response:
        response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
        data.extend(response['Items'])

    # Trả về dữ liệu ở dạng JSON
    return {
        'statusCode': 200,
        'body': json.dumps(data),
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        }
    }
```

   - **Giải thích mã**:  
     - **Kết nối DynamoDB**: Sử dụng `boto3.resource('dynamodb', region_name='us-east-1')` để kết nối đến DynamoDB trong vùng `us-east-1`. Thay `us-east-1` nếu bảng ở vùng khác (ví dụ: `us-west-2`).  
     - **Truy xuất dữ liệu**: Thao tác `table.scan()` lấy toàn bộ dữ liệu từ bảng `studentData`. Vòng lặp `while` xử lý phân trang (DynamoDB giới hạn 1MB mỗi lần Scan).  
     - **Phản hồi**: Trả về dữ liệu JSON với mã trạng thái 200, kèm header `Content-Type: application/json` và `Access-Control-Allow-Origin: '*'` để hỗ trợ CORS cho giao diện web (CloudFront) qua API Gateway.  
   - Kiểm tra `region_name='us-east-1'` khớp với vùng AWS.  
   - Nhấn **Deploy** để lưu và triển khai mã.  

     ![Giao diện chỉnh sửa mã nguồn getStudentData.](/images/4-lambda-functions/1-getstudentdata/lambda-functions-getstudentdata-07.png)
     *Hình 7: Giao diện chỉnh sửa mã nguồn getStudentData.*  
   - Sau khi triển khai, giao diện hiển thị thông báo: _"Successfully updated the function getStudentData."_  

     ![Thông báo triển khai thành công.](/images/4-lambda-functions/1-getstudentdata/lambda-functions-getstudentdata-08.png)
     *Hình 8: Thông báo triển khai thành công.*

7. **Cấu Hình Timeout và Bộ Nhớ**  
   - Trong tab **Configuration** > **General configuration**, nhấn **Edit**.  
   - Đặt **Timeout**: 30 giây (đủ cho thao tác Scan trên bảng lớn).  
   - Đặt **Memory**: 128 MB (mặc định, đủ cho hàm này).  
   - Nhấn **Save**.

8. **Kiểm Tra Hàm**  
   - Trong tab **Test**, nhấn **Create new test event**.  
   - Đặt tên sự kiện (ví dụ: `testGetStudentData`).  
   - Sử dụng JSON mẫu (có thể để trống):  
     ```json
     {}
     ```  
   - Nhấn **Create** để lưu sự kiện, sau đó nhấn **Test** để chạy hàm.  
   - Kiểm tra kết quả:  
     - Nếu bảng `studentData` có dữ liệu (tạo ở mục 2.4), hàm trả về danh sách JSON, ví dụ:  
       ```json
       [
           {"studentid": "SV001", "name": "Nguyen Van A", "class": "CNTT01", "birthdate": "2000-01-01", "email": "student1@example.com"},
           {"studentid": "SV002", "name": "Tran Thi B", "class": "CNTT02", "birthdate": "2001-02-02", "email": "student2@example.com"}
       ]
       ```  
     - Nếu bảng trống, hàm trả về `[]`.  
     - Nếu lỗi, kiểm tra log trong CloudWatch (Monitor > Logs). Các lỗi phổ biến:  
       - _"AccessDenied"_: Kiểm tra `LambdaGetStudentRole` có chính sách `AmazonDynamoDBReadOnlyAccess`.  
       - _"ResourceNotFoundException"_: Đảm bảo bảng `studentData` đã tạo (mục 2.4).  
       - _"Invalid region"_: Kiểm tra `region_name` khớp với vùng AWS.

---

## Lưu Ý Quan Trọng

| **Yếu Tố** | **Chi Tiết** |
|------------|--------------|
| **IAM Role** | Sử dụng `LambdaGetStudentRole` (mục 2.1) với `AWSLambdaBasicExecutionRole`, `AmazonDynamoDBReadOnlyAccess`, `AmazonS3FullAccess`, `CloudFrontFullAccess`. Loại bỏ `AmazonS3FullAccess`, `CloudFrontFullAccess` nếu không dùng để tuân thủ least privilege. |
| **Bảng DynamoDB** | Bảng `studentData` phải tồn tại với `studentid` (Partition Key, String), `name`, `class`, `birthdate`, `email`. Hoàn thành mục 2.4 trước. |
| **CORS** | Header `Access-Control-Allow-Origin: '*'` cần cho giao diện web (CloudFront) gọi qua API Gateway. Cấu hình CORS trong API Gateway sau. |
| **Vùng AWS** | Đảm bảo `region_name='us-east-1'` trong mã khớp với vùng của bảng `studentData`. Cập nhật nếu dùng vùng khác (ví dụ: `us-west-2`). |
| **Xử lý lỗi** | Kiểm tra log trong CloudWatch (`/aws/lambda/getStudentData`) nếu lỗi. Dùng CloudTrail hoặc IAM Access Advisor để xác định vấn đề quyền. |
| **Tối ưu hóa** | Thao tác Scan tốn kém với bảng lớn. Cân nhắc dùng Query với chỉ mục nếu cần lọc dữ liệu (ví dụ: theo `class`). Thêm dữ liệu mẫu vào `studentData` để thử nghiệm. |
| **Kiểm tra sớm** | Chạy kiểm tra để xác minh dữ liệu trả về đúng trước khi tích hợp với API Gateway. |

> **Mẹo thực tiễn**: Thêm dữ liệu mẫu vào bảng `studentData` và kiểm tra log CloudWatch để gỡ lỗi trước khi tích hợp.

---

## Kết Luận

Hàm Lambda `getStudentData` đã được tạo để truy xuất dữ liệu sinh viên từ bảng `studentData`. Hàm sẵn sàng tích hợp với API Gateway.

> **Bước tiếp theo**: Chuyển đến [Tạo hàm insertStudentData](/3-creating-lambda-functions/3.2-create-the-insertstudentdata-function/) để tiếp tục!