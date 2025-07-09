# Workshop-hugo: Triển Khai Website Serverless Quản Lý Thông Tin Sinh Viên với AWS 🚀

![AWS Serverless](https://img.shields.io/badge/AWS-Serverless-orange?logo=amazonaws) ![Duration](https://img.shields.io/badge/Duration-8%20Hours-blue) ![Level](https://img.shields.io/badge/Level-Intermediate-green)

Chào mừng bạn đến với repository **Workshop-hugo**, nơi chứa các tài liệu song ngữ (Anh/Việt) được viết bằng Hugo cho workshop **Triển Khai Website Serverless Quản Lý Thông Tin Sinh Viên với AWS**. Repository này cung cấp hướng dẫn chi tiết cho 12 phần thực hành, từ thiết lập môi trường AWS đến triển khai ứng dụng web serverless, sử dụng các dịch vụ như **S3**, **CloudFront**, **API Gateway**, **Lambda**, **DynamoDB**, **SES**, và **EventBridge**. Đây là tài liệu hỗ trợ chính thức cho workshop, giúp người tham gia dễ dàng theo dõi và triển khai hệ thống.

🔗 **Link Workshop**: [https://nguyentribaothang.github.io/](https://nguyentribaothang.github.io/)  
📂 **Main Repository**: [https://github.com/NguyenTriBaoThang/NguyenTriBaoThang.github.io](https://github.com/NguyenTriBaoThang/NguyenTriBaoThang.github.io)

---

## Giới Thiệu / Introduction

Workshop kéo dài **8 giờ**, hướng dẫn xây dựng một ứng dụng web serverless để quản lý thông tin sinh viên trên AWS. Repository **Workshop-hugo** chứa các trang tài liệu song ngữ (Anh/Việt) được viết bằng Hugo, bao gồm hướng dẫn từng bước cho 12 phần thực hành, từ giới thiệu serverless đến dọn dẹp tài nguyên.  

**The workshop**, lasting **8 hours**, guides participants in building a serverless web application for managing student information on AWS. The **Workshop-hugo** repository hosts bilingual (English/Vietnamese) documentation written in Hugo, covering step-by-step instructions for all 12 practical sections, from serverless introduction to resource cleanup.

---

## Thông Tin Sinh Viên Thực Tập / Internship Student Information

### Nguyễn Tri Bão Thắng  
- **Trường / University**: Đại Học Công nghệ TP.HCM (HUTECH)  
- **MSSV / Student ID**: 2180601452  
- **Gmail**: [nguyentribaothang@gmail.com](mailto:nguyentribaothang@gmail.com)  
- **GitHub**: [NguyenTriBaoThang](https://github.com/NguyenTriBaoThang)  

### Võ Thành Trung  
- **Trường / University**: Đại Học Công nghệ TP.HCM (HUTECH)  
- **MSSV / Student ID**: 2180603167  
- **Gmail**: [vothanhtrung9379@gmail.com](mailto:vothanhtrung9379@gmail.com)  
- **GitHub**: [NguyenTriBaoThang](https://github.com/NguyenTriBaoThang)  

---

## Nội Dung Repository / Repository Contents

Repository **Workshop-hugo** chứa các trang tài liệu Hugo song ngữ (Anh/Việt), tương ứng với 12 phần thực hành của workshop:  

| Trang / Page | Mô Tả / Description | Mục Nhỏ / Subsections |
|--------------|---------------------|------------------------|
| **Tổng Quan / Overview** | Giới thiệu workshop, mục tiêu, lợi ích, và kiến trúc hệ thống. / Introduces the workshop, objectives, benefits, and system architecture. | - |
| **Giới Thiệu / Introduction** | Mô tả thông tin sinh viên, nội dung chính, và công cụ sử dụng. / Describes student information, main content, and tools used. | - |
| **Các Bước Chuẩn Bị / Setup Guide** | Hướng dẫn thiết lập môi trường AWS và công cụ phát triển. / Guides setting up the AWS environment and development tools. | Tạo IAM Role, Tạo bảng DynamoDB, Cấu hình SES, Cài đặt AWS CLI, Tạo S3 bucket. / Create IAM Role, Create DynamoDB table, Configure SES, Install AWS CLI, Create S3 bucket. |
| **Tạo Lambda Functions / Create Lambda Functions** | Hướng dẫn viết các hàm Lambda bằng Python. / Guides writing Lambda functions in Python. | Tạo hàm getStudentData, insertStudentData, BackupDynamoDBAndSendEmail. / Create getStudentData, insertStudentData, BackupDynamoDBAndSendEmail functions. |
| **Cấu Hình RESTful API Bảo Mật bằng API Key / Configure Secure RESTful API with API Key** | Hướng dẫn tạo API REST bảo mật trên API Gateway. / Guides creating a secure REST API on API Gateway. | Tạo REST API, Tạo API Key, Thiết lập Usage Plan, Tạo phương thức GET/POST, Tạo Resource & Method Backup, Kích hoạt CORS, Triển khai API, Gắn API Key. / Create REST API, Create API Key, Set up Usage Plan, Create GET/POST methods, Create Backup Resource & Method, Enable CORS, Deploy API, Attach API Key. |
| **Viết Giao Diện cho Website / Build Website Interface** | Hướng dẫn phát triển giao diện web tĩnh với Tailwind CSS. / Guides building a static web interface with Tailwind CSS. | - |
| **Cấu Hình S3 Bucket / Configure S3 Bucket** | Hướng dẫn cấu hình S3 bucket để lưu trữ và phục vụ website. / Guides configuring S3 bucket for storage and hosting. | Khởi tạo S3 bucket, Tải tài nguyên, Bật Static Website Hosting, Cấu hình Bucket Policy, Hỗ trợ sao lưu. / Create S3 bucket, Upload resources, Enable Static Website Hosting, Configure Bucket Policy, Support backup. |
| **Triển Khai CloudFront / Deploy CloudFront** | Hướng dẫn phân phối website qua CloudFront. / Guides deploying website via CloudFront. | Tạo CloudFront Distribution, Cấu hình Default Root Object, Tạo Invalidation. / Create CloudFront Distribution, Configure Default Root Object, Create Invalidation. |
| **Thiết Lập Backup Hệ Thống Tự Động / Setup Automated System Backup** | Hướng dẫn sao lưu tự động với Lambda và EventBridge. / Guides automated backup with Lambda and EventBridge. | Chỉnh sửa Lambda Backup, Tạo EventBridge Rule. / Configure Lambda Backup, Create EventBridge Rule. |
| **Kiểm Tra Kết Quả Hệ Thống / Verify System Results** | Hướng dẫn kiểm tra hệ thống (giao diện, API, sao lưu). / Guides verifying system (interface, API, backup). | - |
| **Xem Logs Hoạt Động Bằng CloudWatch / Monitor Logs with CloudWatch** | Hướng dẫn phân tích log với CloudWatch Logs Insights. / Guides analyzing logs with CloudWatch Logs Insights. | - |
| **Video Demo Tham Khảo / Reference Video Demo** | Mô tả video demo 35 phút. / Describes 35-minute demo video. | - |
| **Dọn Dẹp Tài Nguyên / Clean Up Resources** | Hướng dẫn xóa tài nguyên để tránh chi phí. / Guides deleting resources to avoid costs. | - |

---

## Hướng Dẫn Cài Đặt và Chạy Dự Án / Setup and Run Instructions

### 1. Clone Mã Nguồn / Clone the Repository
Sao chép mã nguồn từ repository Workshop-hugo:

```bash
git clone https://github.com/NguyenTriBaoThang/Workshop-hugo.git
cd Workshop-hugo
```

### 2. Cài Đặt Hugo / Install Hugo
- Tải và cài đặt Hugo theo hướng dẫn tại [https://gohugo.io/getting-started/installing/](https://gohugo.io/getting-started/installing/).  
- Yêu cầu: Hugo phiên bản 0.80.0 trở lên (khuyến nghị sử dụng Hugo Extended).  

### 3. Cài Đặt Công Cụ Phát Triển / Install Development Tools
- **Node.js** (v16+): Tải từ [https://nodejs.org/](https://nodejs.org/) để quản lý Tailwind CSS.  
- **Visual Studio Code**: Tải từ [https://code.visualstudio.com/](https://code.visualstudio.com/) để chỉnh sửa Markdown.  
- **AWS CLI**: Tải từ [https://aws.amazon.com/cli/](https://aws.amazon.com/cli/) để cấu hình AWS.  
- **Postman**: Tải từ [https://www.postman.com/downloads/](https://www.postman.com/downloads/) để kiểm tra API.  

Cấu hình AWS CLI:
```bash
aws configure
```
Nhập **Access Key**, **Secret Key**, vùng (`us-east-1`), và định dạng đầu ra (`json`).

### 4. Build Trang Web với Hugo / Build the Website with Hugo
Chạy lệnh sau để build các trang Hugo:

```bash
hugo
```

### 5. Chạy Trang Web trên Localhost / Run the Website Locally
Khởi động server Hugo để xem trước các trang:

```bash
hugo server
```
Truy cập [http://localhost:1313](http://localhost:1313) trên trình duyệt để xem nội dung.

### 6. Triển Khai trên GitHub Pages / Deploy to GitHub Pages
- Đẩy thư mục `public` (sau khi chạy `hugo`) lên branch `gh-pages` của repository.  
- Cấu hình GitHub Pages trong **Settings > Pages** để phục vụ từ branch `gh-pages`.  

---

## Yêu Cầu Hệ Thống / System Requirements

- **Hệ Điều Hành / OS**: Windows, macOS, hoặc Linux  
- **AWS Account**: Tài khoản AWS Free Tier (vùng us-east-1)  
- **Công Cụ / Tools**: Hugo (0.80.0+), Node.js (v16+), Visual Studio Code, AWS CLI, Postman  
- **Trình Duyệt / Browser**: Chrome, Firefox, hoặc Edge (hỗ trợ JavaScript)  
- **Kết Nối / Connectivity**: Internet ổn định để truy cập AWS và GitHub  

---

## Tài Liệu Tham Khảo / Resources

- [🔗The First Cloud Journey](https://cloudjourney.awsstudygroup.com/)
- [🌟AWS Special Force Portal](https://specialforce.awsstudygroup.com/)
- [🧠AWS Serverless Workshops](https://aws.amazon.com/serverless/)
- [📖AWS Documentation](https://docs.aws.amazon.com/)
- [🎨Tailwind CSS](https://tailwindcss.com/)
- [☁️VTI Cloud](https://vticloud.io/)

---

## Liên Hệ / Contact

Có thắc mắc hoặc cần hỗ trợ? Liên hệ với chúng tôi:  
- **Nguyễn Tri Bão Thắng**: [nguyentribaothang@gmail.com](mailto:nguyentribaothang@gmail.com)  
- **Võ Thành Trung**: [vothanhtrung9379@gmail.com](mailto:vothanhtrung9379@gmail.com)  

🌟 **Cảm ơn bạn đã quan tâm đến workshop của chúng tôi!** Tham gia để làm chủ công nghệ serverless với AWS! / **Thank you for your interest in our workshop!** Join us to master serverless technology with AWS! 🚀