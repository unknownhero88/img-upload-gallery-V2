<%@ page import="java.sql.*" %>
<%@ page import="com.example.util.DatabaseUtil" %>
<%@ page import="com.example.model.User" %>
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
<title>My Gallery</title>
<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    padding: 20px;
}

.navbar {
    background: rgba(255,255,255,0.95);
    padding: 15px 30px;
    border-radius: 15px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
}

.navbar-brand {
    font-size: 1.5rem;
    font-weight: bold;
    color: #333;
}

.navbar-menu {
    display: flex;
    gap: 20px;
}

.navbar-menu a {
    color: #667eea;
    text-decoration: none;
    padding: 8px 16px;
    border-radius: 8px;
    transition: all 0.3s;
    font-weight: 500;
}

.navbar-menu a:hover {
    background: #667eea;
    color: white;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
}

header {
    text-align: center;
    color: white;
    margin-bottom: 30px;
}

h2 {
    font-size: 2.5rem;
    margin-bottom: 10px;
    text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
}

.upload-btn {
    display: inline-block;
    background: white;
    color: #667eea;
    padding: 12px 30px;
    border-radius: 25px;
    text-decoration: none;
    font-weight: bold;
    margin-top: 15px;
    transition: transform 0.3s, box-shadow 0.3s;
}

.upload-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(0,0,0,0.3);
}

.stats {
    background: rgba(255,255,255,0.9);
    padding: 15px;
    border-radius: 10px;
    text-align: center;
    margin-bottom: 30px;
    color: #333;
}

.gallery {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 20px;
    margin-top: 30px;
}

.card {
    background: white;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    overflow: hidden;
    transition: transform 0.3s, box-shadow 0.3s;
    position: relative;
}

.card:hover {
    transform: translateY(-5px);
    box-shadow: 0 8px 20px rgba(0,0,0,0.25);
}

.image-container {
    width: 100%;
    height: 200px;
    overflow: hidden;
    background: #f0f0f0;
    position: relative;
}

.image-container img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 0.3s;
}

.card:hover .image-container img {
    transform: scale(1.1);
}

.card-footer {
    padding: 15px;
    text-align: center;
}

.view-btn {
    display: inline-block;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 8px 20px;
    border-radius: 20px;
    text-decoration: none;
    font-size: 14px;
    transition: opacity 0.3s;
}

.view-btn:hover {
    opacity: 0.9;
}

.delete-btn {
    display: inline-block;
    background: #dc3545;
    color: white;
    padding: 8px 20px;
    border-radius: 20px;
    text-decoration: none;
    font-size: 14px;
    margin-left: 5px;
    transition: opacity 0.3s;
}

.delete-btn:hover {
    opacity: 0.9;
}

.image-id {
    position: absolute;
    top: 10px;
    left: 10px;
    background: rgba(0,0,0,0.7);
    color: white;
    padding: 5px 10px;
    border-radius: 5px;
    font-size: 12px;
}

.error {
    background: #fff3cd;
    border: 1px solid #ffc107;
    color: #856404;
    padding: 15px;
    border-radius: 8px;
    margin: 20px 0;
    text-align: center;
}

.no-images {
    text-align: center;
    padding: 60px 20px;
    background: rgba(255,255,255,0.9);
    border-radius: 12px;
    color: #666;
}

.no-images h3 {
    margin-bottom: 15px;
    color: #333;
}

.timestamp {
    font-size: 12px;
    color: #666;
    margin-top: 8px;
}

@media (max-width: 768px) {
    .gallery {
        grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
        gap: 15px;
    }
    
    h2 {
        font-size: 1.8rem;
    }
}
</style>
</head>
<body>
<div class="container">
    <nav class="navbar">
        <div class="navbar-brand">📸 Image Gallery</div>
        <div class="navbar-menu">
            <a href="dashboard.jsp">Dashboard</a>
            <a href="upload.jsp">Upload</a>
            <a href="gallery.jsp">Gallery</a>
            <a href="profile.jsp">Profile</a>
            <a href="LogoutServlet">Logout</a>
        </div>
    </nav>

    <header>
        <h2>📸 My Image Gallery</h2>
        <p>Welcome, <%= user.getUsername() %>!</p>
        <a href="upload.jsp" class="upload-btn">+ Upload New Image</a>
    </header>

    <%
    Connection con = null;
    Statement st = null;
    ResultSet rs = null;
    int totalImages = 0;
    
    try {
        con = DatabaseUtil.getConnection();
        st = con.createStatement();
        
        // Count total images for this user
        ResultSet countRs = st.executeQuery("SELECT COUNT(*) as total FROM images WHERE user_id = " + user.getId());
        if (countRs.next()) {
            totalImages = countRs.getInt("total");
        }
        countRs.close();
    %>
    
    <div class="stats">
        <strong>Your Images:</strong> <%= totalImages %>
    </div>

    <div class="gallery">
    <%
        rs = st.executeQuery("SELECT * FROM images WHERE user_id = " + user.getId() + " ORDER BY id DESC");
        
        if (!rs.isBeforeFirst()) {
    %>
            </div>
            <div class="no-images">
                <h3>No images uploaded yet!</h3>
                <p>Click the upload button to add your first image.</p>
            </div>
    <%
        } else {
            while (rs.next()) {
                int imageId = rs.getInt("id");
                String imageUrl = rs.getString("image_url");
                Timestamp uploadedAt = rs.getTimestamp("uploaded_at");
    %>
                <div class="card">
                    <div class="image-container">
                        <span class="image-id">#<%= imageId %></span>
                        <img src="<%= imageUrl %>" alt="Image <%= imageId %>" 
                             onerror="this.src='https://via.placeholder.com/250x200?text=Image+Not+Found'">
                    </div>
                    <div class="card-footer">
                        <a href="<%= imageUrl %>" target="_blank" class="view-btn">View Full</a>
                        <a href="deleteImage.jsp?id=<%= imageId %>" 
                           onclick="return confirm('Are you sure you want to delete this image?')" 
                           class="delete-btn">Delete</a>
                        <% if (uploadedAt != null) { %>
                        <div class="timestamp">
                            <%= new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a").format(uploadedAt) %>
                        </div>
                        <% } %>
                    </div>
                </div>
    <%
            }
        }
    %>
    </div>
    
    <%
    } catch (SQLException e) {
    %>
        <div class="error">
            <strong>Database Error:</strong> <%= e.getMessage() %>
        </div>
    <%
    } catch (Exception e) {
    %>
        <div class="error">
            <strong>Error:</strong> <%= e.getMessage() %>
        </div>
    <%
    } finally {
        try {
            if (rs != null) rs.close();
            if (st != null) st.close();
            if (con != null) con.close();
        } catch (SQLException e) {
            out.println("<div class='error'>Error closing database connection: " + e.getMessage() + "</div>");
        }
    }
    %>
</div>
</body>
</html>