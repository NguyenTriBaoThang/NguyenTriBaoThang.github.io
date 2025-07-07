---
title: "Session Management"
date: 2023-10-25
weight: 1
chapter: false
---

# Triển Khai Website Serverless Quản Lý Thông Tin Sinh Viên với AWS

> **Chào mừng bạn đến với workshop thực tiễn!**  
> Xây dựng một ứng dụng web **serverless** hiện đại, tận dụng các dịch vụ AWS để quản lý thông tin sinh viên một cách **an toàn**, **hiệu quả**, và **tiết kiệm chi phí**.

## Tổng Quan

Workshop này hướng dẫn bạn từng bước xây dựng một **website serverless** sử dụng các dịch vụ AWS mạnh mẽ để quản lý thông tin sinh viên. Ứng dụng hỗ trợ:  
- **Nhập và xuất dữ liệu sinh viên** với các trường: **Mã sinh viên**, **Họ tên**, **Lớp**, **Ngày sinh**, và **Email**.  
- **Giao diện trực quan** được thiết kế với **Tailwind CSS**, mang lại trải nghiệm người dùng mượt mà.  
- **Bảo mật**: Sử dụng **API Key** qua **API Gateway** để xác thực yêu cầu.  
- **Thông báo**: Gửi email xác nhận và sao lưu qua **AWS SES**.  
- **Sao lưu tự động**: Lưu dữ liệu từ **DynamoDB** vào **S3** theo lịch trình.  

Bằng cách sử dụng các dịch vụ serverless như **S3**, **DynamoDB**, **Lambda**, **API Gateway**, **CloudFront**, và **SES**, bạn sẽ học cách triển khai một ứng dụng:  
- **Không cần quản lý máy chủ**.  
- **Tiết kiệm chi phí** với mô hình trả phí theo sử dụng.  
- **Tự động mở rộng** theo lưu lượng truy cập.  
- **Tối ưu hiệu suất toàn cầu** với độ trễ thấp.

**Kiến trúc hệ thống tổng quan**:

![Kiến trúc hệ thống serverless](/images/system-architecture-overview.jpg)
*Hình 1: Sơ đồ tổng quan kiến trúc ứng dụng serverless với các dịch vụ AWS.*

---

## Nội Dung Workshop

Workshop bao gồm các bước chi tiết để xây dựng ứng dụng serverless hoàn chỉnh. Dưới đây là danh sách các nội dung:

| **Bước** | **Nội Dung** | **Mô Tả** |
|----------|--------------|-----------|
| 1 | [Giới thiệu](1-introduction/) | Tổng quan về workshop, lợi ích của kiến trúc serverless, và mục tiêu học tập. |
| 2 | [Các bước chuẩn bị](2-preparation-steps/)  | Hướng dẫn thiết lập tài khoản AWS, cài đặt công cụ cần thiết, và chuẩn bị môi trường. |
| 3 | [Cấu hình Lambda Functions](3-creating-lambda-functions/) | Tạo các hàm Lambda để xử lý logic, như truy xuất và lưu trữ dữ liệu sinh viên. |
| 4 | [Tạo RESTful API](1-Introduction/) | Cấu hình API Gateway để tạo API an toàn, tích hợp với Lambda. |
| 5 | [Viết giao diện cho Website](1-Introduction/) | Thiết kế giao diện web với Tailwind CSS để nhập/xuất dữ liệu sinh viên. |
| 6 | [Cấu hình S3 Bucket](1-Introduction/)| Tạo và cấu hình bucket S3 để lưu trữ nội dung tĩnh và dữ liệu sao lưu. |
| 7 | [Triển khai CloudFront](1-Introduction/) | Sử dụng CloudFront để phân phối nội dung toàn cầu với độ trễ thấp. |
| 8 | [Thiết lập Backup hệ thống](1-Introduction/) | Tự động hóa sao lưu dữ liệu từ DynamoDB vào S3 với EventBridge. |
| 9 | [Kiểm tra kết quả](1-Introduction/) | Xác minh hoạt động của ứng dụng qua các kịch bản kiểm thử. |
| 10 | [Xem Logs hoạt động bằng CloudWatch](1-Introduction/) | Theo dõi và phân tích log hệ thống để tối ưu hiệu suất. |
| 11 | [Video Demo tham khảo](1-Introduction/)| Xem video hướng dẫn minh họa cách ứng dụng hoạt động. |
| 12 | [Dọn dẹp tài nguyên](1-Introduction/) | Hướng dẫn xóa các tài nguyên AWS để tránh chi phí không cần thiết. |

> **Lưu ý**: Mỗi bước được thiết kế để bạn thực hành từng phần của ứng dụng, từ cấu hình cơ sở dữ liệu đến triển khai giao diện và giám sát hệ thống. Hãy làm theo thứ tự để đạt kết quả tốt nhất.

---

## Bắt Đầu Hành Trình

Hoàn thành workshop này, bạn sẽ:  
- Sở hữu một **ứng dụng serverless hoàn chỉnh**, sẵn sàng sử dụng trong thực tế.  
- Nắm vững **kỹ năng thực tiễn** để tích hợp các dịch vụ AWS như Lambda, DynamoDB, API Gateway, S3, CloudFront, SES, và CloudWatch.  
- Tự tin phát triển các ứng dụng serverless khác trong tương lai.

> **Sẵn sàng bắt đầu?**  
> Chuyển đến [Giới thiệu](1-introduction/) để khám phá chi tiết về ứng dụng và lợi ích của kiến trúc serverless!