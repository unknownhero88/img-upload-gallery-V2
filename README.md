# 📸 Image Gallery Web Application

A full-featured image gallery web application built with Java Servlets, JSP, MySQL, and ImgBB API. Features include user authentication, image upload/management, activity logging, and user profiles.

## ✨ Features

### 🔐 Authentication System
- User Registration with validation
- Secure Login/Logout
- Password hashing (SHA-256)
- Session management
- Protected routes

### 📷 Image Management
- Upload images with drag & drop support
- Automatic image compression & optimization
- Cloud storage via ImgBB API
- View personal gallery
- Delete images
- Image metadata (upload date, views)

### 👤 User Profile
- User dashboard with statistics
- Profile page with bio and details
- Activity logs with pagination
- IP tracking and user agent logging

### 📊 Activity Tracking
- All user actions logged to database
- Detailed activity history
- Action types: LOGIN, LOGOUT, SIGNUP, IMAGE_UPLOAD, IMAGE_DELETE
- Timestamp and IP address tracking

## 🛠️ Tech Stack

- **Backend:** Java 17, Jakarta Servlets 6.0
- **Frontend:** JSP, HTML5, CSS3, JavaScript
- **Database:** MySQL 8.0
- **Build Tool:** Maven
- **Server:** Embedded Tomcat 10.1
- **Image Storage:** ImgBB API

## 📁 Project Structure

```
Img-Url-con/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/example/
│       │       ├── Main.java                    # Main application entry
│       │       ├── model/
│       │       │   └── User.java                # User model
│       │       ├── servlet/
│       │       │   ├── LoginServlet.java        # Login handler
│       │       │   ├── SignupServlet.java       # Signup handler
│       │       │   ├── LogoutServlet.java       # Logout handler
│       │       │   └── UploadImageServlet.java  # Image upload handler
│       │       └── util/
│       │           ├── DatabaseUtil.java        # Database connection
│       │           ├── PasswordUtil.java        # Password hashing
│       │           └── ActivityLogger.java      # Activity logging
│       └── webapp/
│           ├── index.jsp                        # Landing page
│           ├── login.jsp                        # Login page
│           ├── signup.jsp                       # Signup page
│           ├── dashboard.jsp                    # User dashboard
│           ├── profile.jsp                      # User profile & logs
│           ├── gallery.jsp                      # Image gallery
│           ├── upload.html                      # Upload form
│           └── deleteImage.jsp                  # Delete handler
├── pom.xml                                      # Maven configuration
├── Dockerfile                                   # Docker configuration
└── README.md                                    # This file
```

## 🚀 Getting Started

### Prerequisites

- Java 17 or higher
- Maven 3.6+
- MySQL 8.0+
- ImgBB API Key (free at https://api.imgbb.com/)

### Database Setup

1. Create database and tables:

```sql
CREATE DATABASE javabase;
USE javabase;

-- Run the complete SQL from database.sql artifact
```

2. Update database credentials in `DatabaseUtil.java` or use environment variables:

```
DB_URL=jdbc:mysql://localhost:3306/javabase
DB_USER=root
DB_PASSWORD=your_password
```

### Local Development

1. Clone the repository:
```bash
git clone https://github.com/unknownhero88/img-upload-gallery.git
cd img-upload-gallery
```

2. Build the project:
```bash
mvn clean package
```

3. Run the application:
```bash
java -jar target/Img-Url-con.jar
```

4. Access the application:
```
http://localhost:10000
```

### Environment Variables

Set these environment variables:

```bash
PORT=10000
DB_URL=jdbc:mysql://localhost:3306/javabase
DB_USER=root
DB_PASSWORD=your_password
IMGBB_API_KEY=your_imgbb_api_key
```

## 🐳 Docker Deployment

1. Build Docker image:
```bash
docker build -t img-gallery .
```

2. Run container:
```bash
docker run -p 10000:10000 \
  -e DB_URL=jdbc:mysql://host:3306/javabase \
  -e DB_USER=root \
  -e DB_PASSWORD=password \
  -e IMGBB_API_KEY=your_key \
  img-gallery
```

## ☁️ Cloud Deployment

### Railway (Recommended)

1. Go to [railway.app](https://railway.app)
2. Create new project from GitHub repo
3. Add MySQL database
4. Set environment variables
5. Deploy!

### Render

1. Go to [render.com](https://render.com)
2. Create new Web Service
3. Connect GitHub repository
4. Select Docker environment
5. Set environment variables
6. Deploy

## 📝 Default Admin Account

For testing purposes, a default admin account is created:

```
Username: admin
Email: admin@example.com
Password: admin123
```

**⚠️ Important:** Change this password immediately in production!

## 🔒 Security Features

- Password hashing with SHA-256
- SQL injection prevention (PreparedStatements)
- Session-based authentication
- CSRF protection
- Input validation
- Secure file upload validation
- Activity logging for audit trails

## 📊 Database Schema

### Users Table
- id, username, email, password (hashed)
- full_name, profile_picture, bio
- created_at, last_login, is_active

### Images Table
- id, user_id (FK), image_url
- title, description, uploaded_at, views

### Activity Logs Table
- id, user_id (FK), action
- description, ip_address, user_agent, created_at

## 🎨 Features in Detail

### Image Upload
- Max file size: 5MB
- Supported formats: JPG, PNG, GIF, WEBP
- Automatic compression and resize (max 1920x1080)
- Progress indicator
- Drag & drop support

### User Dashboard
- Statistics: Total images, views, recent uploads, activities
- Recent images preview (6 most recent)
- Quick actions: Upload, View Gallery, Profile

### Activity Logs
- Paginated view (20 per page)
- Color-coded action badges
- IP address and timestamp tracking
- Filtering by action type

## 🧪 Testing

Run tests:
```bash
mvn test
```

## 📈 Performance

- Image compression reduces file size by ~70-80%
- Lazy loading for gallery images
- Database connection pooling
- Session management for scalability

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

**Unknown Hero**
- GitHub: [@unknownhero88](https://github.com/unknownhero88)

## 🙏 Acknowledgments

- [ImgBB](https://imgbb.com/) for image hosting API
- [Apache Tomcat](https://tomcat.apache.org/) for servlet container
- [MySQL](https://www.mysql.com/) for database

## 📞 Support

For support, email support@example.com or open an issue on GitHub.

---

Made with ❤️ using Java, MySQL, and lots of coffee ☕