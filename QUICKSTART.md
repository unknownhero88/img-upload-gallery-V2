# 🚀 Quick Start Guide

## 5-Minute Setup

### Step 1: Database Setup (2 minutes)

```sql
-- Create database
CREATE DATABASE javabase;
USE javabase;

-- Copy and run the complete SQL from database.sql
-- It will create users, images, and activity_logs tables
```

### Step 2: Build & Run (2 minutes)

```bash
# Navigate to project
cd Img-Url-con

# Build
mvn clean package

# Run
java -jar target/Img-Url-con.jar
```

### Step 3: Access (1 minute)

```
http://localhost:10000
```

**Default Login:**
- Username: `admin`
- Password: `admin123`

---

## 📋 File Checklist

Make sure these files exist in your project:

### Java Files (src/main/java/com/example/)
- ✅ Main.java
- ✅ model/User.java
- ✅ servlet/LoginServlet.java
- ✅ servlet/SignupServlet.java
- ✅ servlet/LogoutServlet.java
- ✅ servlet/UploadImageServlet.java (update existing)
- ✅ util/DatabaseUtil.java
- ✅ util/PasswordUtil.java
- ✅ util/ActivityLogger.java

### JSP Files (src/main/webapp/)
- ✅ index.jsp
- ✅ login.jsp
- ✅ signup.jsp
- ✅ dashboard.jsp
- ✅ profile.jsp
- ✅ gallery.jsp (update existing)
- ✅ upload.html (update existing)
- ✅ deleteImage.jsp (update existing)

### Config Files
- ✅ pom.xml
- ✅ Dockerfile (optional for deployment)

---

## 🔧 Common Issues & Fixes

### Issue 1: "Cannot connect to database"
```bash
# Check MySQL is running
mysql -u root -p

# Verify credentials in DatabaseUtil.java or env variables
```

### Issue 2: "ClassNotFoundException: com.mysql.cj.jdbc.Driver"
```bash
# Maven dependency missing, run:
mvn clean install -U
```

### Issue 3: "Port 10000 already in use"
```bash
# Change port in Main.java or use environment variable:
export PORT=8080
java -jar target/Img-Url-con.jar
```

### Issue 4: "NoClassDefFoundError: jakarta/servlet"
```bash
# Wrong Tomcat version or dependencies
# Check pom.xml has correct jakarta dependencies (not javax)
```

---

## 🎯 Testing Checklist

After setup, test these features:

- [ ] Visit homepage (index.jsp)
- [ ] Create new account (signup)
- [ ] Login with new account
- [ ] Upload an image
- [ ] View gallery
- [ ] Delete an image
- [ ] Check dashboard statistics
- [ ] View profile and activity logs
- [ ] Logout

---

## 📱 API Endpoints

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|---------------|
| / | GET | Home page | No |
| /login.jsp | GET | Login page | No |
| /signup.jsp | GET | Signup page | No |
| /LoginServlet | POST | Login handler | No |
| /SignupServlet | POST | Signup handler | No |
| /LogoutServlet | GET | Logout handler | Yes |
| /dashboard.jsp | GET | User dashboard | Yes |
| /profile.jsp | GET | User profile | Yes |
| /gallery.jsp | GET | Image gallery | Yes |
| /UploadImageServlet | POST | Upload image | Yes |
| /deleteImage.jsp | GET | Delete image | Yes |

---

## 🌐 Deployment Quick Commands

### Railway
```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Deploy
railway up
```

### Docker
```bash
# Build
docker build -t img-gallery .

# Run
docker run -p 10000:10000 \
  -e DB_URL=your_db_url \
  -e DB_USER=root \
  -e DB_PASSWORD=password \
  img-gallery
```

### Manual WAR Deployment
```bash
# Build WAR
mvn clean package -Pwar

# Copy to Tomcat
cp target/Img-Url-con.war /path/to/tomcat/webapps/
```

---

## 💡 Pro Tips

1. **Use Environment Variables** for sensitive data
2. **Enable HTTPS** in production
3. **Regular database backups** are essential
4. **Monitor activity logs** for suspicious activities
5. **Update dependencies** regularly

---

## 🆘 Need Help?

1. Check README.md for detailed documentation
2. Review error logs in console
3. Verify database connection
4. Check firewall/port settings
5. Open an issue on GitHub

---

**Ready to go? Start with Step 1! 🚀**