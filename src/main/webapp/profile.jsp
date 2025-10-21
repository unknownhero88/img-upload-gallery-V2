<%@ page import="com.example.model.User" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.example.util.DatabaseUtil" %>
<%@ page import="java.text.SimpleDateFormat" %>
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
<title>Profile - <%= user.getUsername() %></title>
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

.container {
    max-width: 1200px;
    margin: 30px auto;
    padding: 0 20px;
}

.profile-header {
    background: white;
    padding: 40px;
    border-radius: 15px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    margin-bottom: 20px;
    display: flex;
    gap: 30px;
    align-items: center;
}

.profile-pic-large {
    width: 120px;
    height: 120px;
    border-radius: 50%;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 3rem;
    font-weight: bold;
}

.profile-info h1 {
    color: #333;
    margin-bottom: 10px;
}

.profile-info p {
    color: #666;
    margin: 5px 0;
}

.profile-info .badge {
    display: inline-block;
    background: #e3f2fd;
    color: #1976d2;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 0.85rem;
    margin-top: 10px;
}

.section {
    background: white;
    padding: 25px;
    border-radius: 15px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    margin-bottom: 20px;
}

.section-title {
    font-size: 1.5rem;
    color: #333;
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 2px solid #f0f0f0;
}

.activity-list {
    list-style: none;
}

.activity-item {
    padding: 15px;
    border-left: 3px solid #667eea;
    background: #f8f9fa;
    margin-bottom: 10px;
    border-radius: 8px;
    transition: transform 0.2s;
}

.activity-item:hover {
    transform: translateX(5px);
}

.activity-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 5px;
}

.activity-action {
    font-weight: bold;
    color: #333;
}

.activity-time {
    color: #999;
    font-size: 0.85rem;
}

.activity-description {
    color: #666;
    font-size: 0.9rem;
}

.activity-meta {
    display: flex;
    gap: 15px;
    margin-top: 8px;
    font-size: 0.8rem;
    color: #999;
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

.btn-primary {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
}

.btn:hover {
    transform: translateY(-2px);
}

.empty-state {
    text-align: center;
    padding: 60px 20px;
    color: #999;
}

.pagination {
    display: flex;
    justify-content: center;
    gap: 10px;
    margin-top: 20px;
}

.pagination a {
    padding: 8px 15px;
    background: #f0f0f0;
    color: #333;
    text-decoration: none;
    border-radius: 5px;
    transition: background 0.3s;
}

.pagination a:hover,
.pagination a.active {
    background: #667eea;
    color: white;
}

.action-badge {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 12px;
    font-size: 0.75rem;
    font-weight: 500;
}

.action-login { background: #e8f5e9; color: #2e7d32; }
.action-logout { background: #fff3e0; color: #ef6c00; }
.action-signup { background: #e3f2fd; color: #1976d2; }
.action-upload { background: #f3e5f5; color: #7b1fa2; }
.action-delete { background: #ffebee; color: #c62828; }
.action-view { background: #e0f2f1; color: #00695c; }
</style>
</head>
<body>

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

<div class="container">
    <%
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            
            // Refresh user data
            String userSql = "SELECT * FROM users WHERE id = ?";
            ps = conn.prepareStatement(userSql);
            ps.setInt(1, user.getId());
            rs = ps.executeQuery();
            
            if (rs.next()) {
                user.setFullName(rs.getString("full_name"));
                user.setEmail(rs.getString("email"));
                user.setBio(rs.getString("bio"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                user.setLastLogin(rs.getTimestamp("last_login"));
            }
            rs.close();
            ps.close();
    %>
    
    <div class="profile-header">
        <div class="profile-pic-large">
            <% if (user.getProfilePicture() != null) { %>
                <img src="<%= user.getProfilePicture() %>" style="width:100%; height:100%; object-fit:cover; border-radius:50%;">
            <% } else { %>
                <%= user.getUsername().substring(0,1).toUpperCase() %>
            <% } %>
        </div>
        
        <div class="profile-info">
            <h1><%= user.getFullName() != null ? user.getFullName() : user.getUsername() %></h1>
            <p>@<%= user.getUsername() %></p>
            <p>📧 <%= user.getEmail() %></p>
            <% if (user.getBio() != null && !user.getBio().isEmpty()) { %>
                <p>📝 <%= user.getBio() %></p>
            <% } %>
            <span class="badge">Member since <%= new SimpleDateFormat("MMM yyyy").format(user.getCreatedAt()) %></span>
            <% if (user.getLastLogin() != null) { %>
                <p style="margin-top:10px; color:#999; font-size:0.9rem;">
                    Last login: <%= new SimpleDateFormat("MMM dd, yyyy hh:mm a").format(user.getLastLogin()) %>
                </p>
            <% } %>
        </div>
    </div>
    
    <div class="section">
        <h2 class="section-title">📊 Activity Logs</h2>
        
        <%
            // Get page number
            int currentPage = 1;
            int recordsPerPage = 20;
            
            if (request.getParameter("page") != null) {
            	currentPage = Integer.parseInt(request.getParameter("page"));
            }
            
            // Count total activities
            String countSql = "SELECT COUNT(*) as total FROM activity_logs WHERE user_id = ?";
            ps = conn.prepareStatement(countSql);
            ps.setInt(1, user.getId());
            rs = ps.executeQuery();
            
            int totalRecords = 0;
            if (rs.next()) {
                totalRecords = rs.getInt("total");
            }
            rs.close();
            ps.close();
            
            int totalPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);
            
            // Get activities
            String activitySql = "SELECT * FROM activity_logs WHERE user_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?";
            ps = conn.prepareStatement(activitySql);
            ps.setInt(1, user.getId());
            ps.setInt(2, recordsPerPage);
            ps.setInt(3, (currentPage - 1) * recordsPerPage);
            rs = ps.executeQuery();
            
            boolean hasActivities = false;
            SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy hh:mm a");
        %>
        
        <ul class="activity-list">
            <%
                while (rs.next()) {
                    hasActivities = true;
                    String action = rs.getString("action");
                    String description = rs.getString("description");
                    String ipAddress = rs.getString("ip_address");
                    Timestamp createdAt = rs.getTimestamp("created_at");
                    
                    String badgeClass = "action-badge ";
                    if (action.contains("LOGIN")) badgeClass += "action-login";
                    else if (action.contains("LOGOUT")) badgeClass += "action-logout";
                    else if (action.contains("SIGNUP")) badgeClass += "action-signup";
                    else if (action.contains("UPLOAD")) badgeClass += "action-upload";
                    else if (action.contains("DELETE")) badgeClass += "action-delete";
                    else if (action.contains("VIEW")) badgeClass += "action-view";
            %>
                <li class="activity-item">
                    <div class="activity-header">
                        <span class="activity-action">
                            <span class="<%= badgeClass %>"><%= action %></span>
                        </span>
                        <span class="activity-time"><%= sdf.format(createdAt) %></span>
                    </div>
                    <% if (description != null && !description.isEmpty()) { %>
                        <div class="activity-description"><%= description %></div>
                    <% } %>
                    <div class="activity-meta">
                        <span>🌐 IP: <%= ipAddress != null ? ipAddress : "Unknown" %></span>
                    </div>
                </li>
            <%
                }
                
                if (!hasActivities) {
            %>
                <div class="empty-state">
                    <p>No activity logs yet</p>
                </div>
            <%
                }
            %>
        </ul>
        
        <% if (totalPages > 1) { %>
            <div class="pagination">
                <% if (currentPage > 1) { %>
                    <a href="profile.jsp?page=<%= currentPage - 1 %>">← Previous</a>
                <% } %>
                
                <% for (int i = 1; i <= totalPages; i++) { %>
                    <a href="profile.jsp?page=<%= i %>" class="<%= i == currentPage ? "active" : "" %>"><%= i %></a>
                <% } %>
                
                <% if (currentPage < totalPages) { %>
                    <a href="profile.jsp?page=<%= currentPage + 1 %>">Next →</a>
                <% } %>
            </div>
        <% } %>
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