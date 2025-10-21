<%@ page import="com.example.model.User" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.example.util.DatabaseUtil" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dashboard - Image Gallery</title>
<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: #f5f6fa;
}

.navbar {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    padding: 15px 30px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.navbar-brand {
    color: white;
    font-size: 1.5rem;
    font-weight: bold;
}

.navbar-menu {
    display: flex;
    gap: 20px;
    align-items: center;
}

.navbar-menu a {
    color: white;
    text-decoration: none;
    padding: 8px 16px;
    border-radius: 8px;
    transition: background 0.3s;
}

.navbar-menu a:hover {
    background: rgba(255,255,255,0.2);
}

.user-info {
    display: flex;
    align-items: center;
    gap: 10px;
    color: white;
}

.profile-pic {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background: white;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.2rem;
}

.container {
    max-width: 1200px;
    margin: 30px auto;
    padding: 0 20px;
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
}

.stat-card {
    background: white;
    padding: 25px;
    border-radius: 15px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    display: flex;
    align-items: center;
    gap: 20px;
}

.stat-icon {
    font-size: 2.5rem;
    width: 60px;
    height: 60px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
}

.stat-icon.blue { background: #e3f2fd; }
.stat-icon.green { background: #e8f5e9; }
.stat-icon.purple { background: #f3e5f5; }
.stat-icon.orange { background: #fff3e0; }

.stat-info h3 {
    font-size: 2rem;
    color: #333;
    margin-bottom: 5px;
}

.stat-info p {
    color: #666;
    font-size: 0.9rem;
}

.section {
    background: white;
    padding: 25px;
    border-radius: 15px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    margin-bottom: 20px;
}

.section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}

.section-title {
    font-size: 1.5rem;
    color: #333;
}

.btn {
    padding: 10px 20px;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 500;
    text-decoration: none;
    display: inline-block;
    transition: transform 0.3s;
}

.btn:hover {
    transform: translateY(-2px);
}

.btn-primary {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
}

.btn-danger {
    background: #dc3545;
    color: white;
}

.gallery-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 15px;
}

.image-card {
    position: relative;
    border-radius: 10px;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    transition: transform 0.3s;
}

.image-card:hover {
    transform: translateY(-5px);
}

.image-card img {
    width: 100%;
    height: 200px;
    object-fit: cover;
}

.image-actions {
    position: absolute;
    top: 10px;
    right: 10px;
    display: flex;
    gap: 5px;
}

.image-actions a {
    background: rgba(0,0,0,0.6);
    color: white;
    padding: 5px 10px;
    border-radius: 5px;
    text-decoration: none;
    font-size: 0.8rem;
}

.empty-state {
    text-align: center;
    padding: 60px 20px;
    color: #999;
}

.empty-state-icon {
    font-size: 4rem;
    margin-bottom: 20px;
}
</style>
</head>
<body>

<nav class="navbar">
    <div class="navbar-brand">📸 Image Gallery</div>
    <div class="navbar-menu">
        <a href="dashboard.jsp">Dashboard</a>
        <a href="upload.jsp">Upload</a>
        <a href="gallery.jsp">Gallery</a>
        <div class="user-info">
            <div class="profile-pic">
                <% if (user.getProfilePicture() != null) { %>
                    <img src="<%= user.getProfilePicture() %>" style="width:100%; height:100%; object-fit:cover; border-radius:50%;">
                <% } else { %>
                    <%= user.getUsername().substring(0,1).toUpperCase() %>
                <% } %>
            </div>
            <span><%= user.getUsername() %></span>
        </div>
        <a href="profile.jsp">Profile</a>
        <a href="LogoutServlet">Logout</a>
    </div>
</nav>

<div class="container">
    <h1 style="margin-bottom: 30px;">Welcome back, <%= user.getFullName() != null ? user.getFullName() : user.getUsername() %>! 👋</h1>
    
    <%
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        int totalImages = 0;
        int totalViews = 0;
        int recentUploads = 0;
        int totalActivities = 0;
        
        try {
            conn = DatabaseUtil.getConnection();
            
            // Get statistics
            String statsSql = "SELECT COUNT(*) as total, COALESCE(SUM(views), 0) as views FROM images WHERE user_id = ?";
            ps = conn.prepareStatement(statsSql);
            ps.setInt(1, user.getId());
            rs = ps.executeQuery();
            if (rs.next()) {
                totalImages = rs.getInt("total");
                totalViews = rs.getInt("views");
            }
            rs.close();
            ps.close();
            
            // Recent uploads (last 7 days)
            String recentSql = "SELECT COUNT(*) as recent FROM images WHERE user_id = ? AND uploaded_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)";
            ps = conn.prepareStatement(recentSql);
            ps.setInt(1, user.getId());
            rs = ps.executeQuery();
            if (rs.next()) {
                recentUploads = rs.getInt("recent");
            }
            rs.close();
            ps.close();
            
            // Total activities
            String activitySql = "SELECT COUNT(*) as activities FROM activity_logs WHERE user_id = ?";
            ps = conn.prepareStatement(activitySql);
            ps.setInt(1, user.getId());
            rs = ps.executeQuery();
            if (rs.next()) {
                totalActivities = rs.getInt("activities");
            }
    %>
    
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon blue">📷</div>
            <div class="stat-info">
                <h3><%= totalImages %></h3>
                <p>Total Images</p>
            </div>
        </div>
        
        <div class="stat-card">
            <div class="stat-icon green">👁️</div>
            <div class="stat-info">
                <h3><%= totalViews %></h3>
                <p>Total Views</p>
            </div>
        </div>
        
        <div class="stat-card">
            <div class="stat-icon purple">🆕</div>
            <div class="stat-info">
                <h3><%= recentUploads %></h3>
                <p>Recent Uploads (7 days)</p>
            </div>
        </div>
        
        <div class="stat-card">
            <div class="stat-icon orange">📊</div>
            <div class="stat-info">
                <h3><%= totalActivities %></h3>
                <p>Activities Logged</p>
            </div>
        </div>
    </div>
    
    <div class="section">
        <div class="section-header">
            <h2 class="section-title">Your Recent Images</h2>
            <a href="upload.jsp" class="btn btn-primary">+ Upload New</a>
        </div>
        
        <div class="gallery-grid">
            <%
                String imagesSql = "SELECT * FROM images WHERE user_id = ? ORDER BY uploaded_at DESC LIMIT 6";
                ps = conn.prepareStatement(imagesSql);
                ps.setInt(1, user.getId());
                rs = ps.executeQuery();
                
                boolean hasImages = false;
                while (rs.next()) {
                    hasImages = true;
                    int imageId = rs.getInt("id");
                    String imageUrl = rs.getString("image_url");
            %>
                <div class="image-card">
                    <img src="<%= imageUrl %>" alt="Image">
                    <div class="image-actions">
                        <a href="<%= imageUrl %>" target="_blank">View</a>
                        <a href="deleteImage.jsp?id=<%= imageId %>" onclick="return confirm('Delete this image?')" class="btn-danger">Delete</a>
                    </div>
                </div>
            <%
                }
                
                if (!hasImages) {
            %>
                <div class="empty-state" style="grid-column: 1/-1;">
                    <div class="empty-state-icon">📸</div>
                    <h3>No images uploaded yet</h3>
                    <p>Start uploading your first image!</p>
                    <br>
                    <a href="upload.jsp" class="btn btn-primary">Upload Image</a>
                </div>
            <%
                }
            %>
        </div>
    </div>
    
    <%
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    %>
</div>

</body>
</html>