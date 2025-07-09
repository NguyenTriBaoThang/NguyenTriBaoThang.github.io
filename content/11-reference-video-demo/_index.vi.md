
---
title: "Video Demo Tham Khảo"
date: 2023-10-25
weight: 11
chapter: false
pre: "<b>11. </b>"
---

> **Mục tiêu**: Cung cấp video demo minh họa quy trình triển khai và kiểm tra website serverless quản lý thông tin sinh viên trên AWS, tích hợp S3, CloudFront, API Gateway, Lambda, DynamoDB, SES, và EventBridge. Video giúp hình dung cách xây dựng ứng dụng, từ cấu hình cơ sở hạ tầng đến kiểm tra chức năng nhập thông tin sinh viên, xem danh sách, gửi email, và backup dữ liệu tự động.

---

## Nội Dung Video Demo

- Video minh họa các bước triển khai và kiểm tra hệ thống serverless
- Link Demo tham khảo: [Tại đây](https://drive.google.com/file/d/1Tjlm74NRt5Dq5NhBiH9JJ4sQtsFQU0DB/view?usp=drive_link)

---

## Thời Lượng Video

- **Đề xuất**: 35 phút, bao quát các bước chính.  
- **Chia đoạn**:  
  - Cấu hình AWS (10 phút).  
  - Giao diện web (10 phút).  
  - Kiểm tra backend và backup (15 phút).  
  - **Timestamps** để dễ theo dõi (VD: 00:00–10:00: Cấu hình AWS, 10:01–20:00: Giao diện web).  

---

## Nguồn Tham Khảo Video Demo

Nếu chưa có video cụ thể, tham khảo các nguồn:  
- **AWS Serverless Workshops**: Hướng dẫn tại [aws.amazon.com/serverless-workshops](https://aws.amazon.com/serverless-workshops), bao gồm video xây dựng ứng dụng serverless (VD: "danh sách việc cần làm" với Lambda, API Gateway, DynamoDB, Amplify).  [](https://aws.amazon.com/getting-started/hands-on/build-web-app-s3-lambda-api-gateway-dynamodb/)
- **VTI Cloud**: Video cấu hình Lambda, S3, API Gateway, DynamoDB tại [vticloud.io](https://vticloud.io), minh họa xử lý file và backup.  
- **Techmaster Vietnam**: Khóa học "Learn AWS the Hard Way" tại [techmaster.vn](https://techmaster.vn) với video thực hành serverless (API Gateway, Lambda, DynamoDB).   

---

## Hướng Dẫn Sử Dụng Video Demo

1. Xem video để hiểu quy trình triển khai và kiểm tra.  
2. So sánh với cấu hình AWS Console của bạn (S3, CloudFront, Lambda, v.v.).  
3. Thực hiện lại các bước trên tài khoản AWS, sử dụng AWS.  
4. Nếu gặp lỗi, tham khảo mục 9 (Kiểm tra kết quả) và mục 10 (CloudWatch Logs).  
5. Tùy chỉnh mã nguồn (`index.html`, `scripts.js`, Lambda functions) nếu cần.  

> **Mẹo thực tiễn**: Xem video với tốc độ 1.5x để tiết kiệm thời gian. Ghi chú các bước cấu hình và so sánh với hệ thống của bạn. Test thủ công **POST /backup** trước khi dựa vào lịch tự động.

---

## Kết Luận

Video demo minh họa toàn bộ quy trình triển khai website serverless quản lý sinh viên, từ cấu hình AWS (S3, CloudFront, API Gateway, Lambda, DynamoDB, SES, EventBridge) đến kiểm tra chức năng (lưu, xem, backup, email). Sử dụng video để củng cố hiểu biết và tối ưu hóa hệ thống.

> **Bước tiếp theo**: Xem lại log CloudWatch (mục 10) để phân tích hiệu suất và triển khai cải tiến nếu cần!