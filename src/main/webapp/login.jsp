<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Login - Image Gallery</title>
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
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 20px;
}

.login-container {
    background: white;
    padding: 40px;
    border-radius: 20px;
    box-shadow: 0 20px 60px rgba(0,0,0,0.3);
    max-width: 400px;
    width: 100%;
}

.logo {
    text-align: center;
    font-size: 3rem;
    margin-bottom: 10px;
}

h2 {
    text-align: center;
    color: #333;
    margin-bottom: 30px;
}

.form-group {
    margin-bottom: 20px;
}

label {
    display: block;
    color: #555;
    margin-bottom: 8px;
    font-weight: 500;
}

input[type="text"],
input[type="password"] {
    width: 100%;
    padding: 12px 15px;
    border: 2px solid #e0e0e0;
    border-radius: 10px;
    font-size: 14px;
    transition: border 0.3s;
}

input[type="text"]:focus,
input[type="password"]:focus {
    outline: none;
    border-color: #667eea;
}

.btn {
    width: 100%;
    padding: 14px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border: none;
    border-radius: 10px;
    font-size: 16px;
    font-weight: bold;
    cursor: pointer;
    transition: transform 0.3s;
}

.btn:hover {
    transform: translateY(-2px);
}

.error {
    background: #fee;
    color: #c33;
    padding: 12px;
    border-radius: 8px;
    margin-bottom: 20px;
    border-left: 4px solid #c33;
}

.success {
    background: #efe;
    color: #3c3;
    padding: 12px;
    border-radius: 8px;
    margin-bottom: 20px;
    border-left: 4px solid #3c3;
}

.signup-link {
    text-align: center;
    margin-top: 20px;
    color: #666;
}

.signup-link a {
    color: #667eea;
    text-decoration: none;
    font-weight: bold;
}

.signup-link a:hover {
    text-decoration: underline;
}
</style>
</head>
<body>
<div class="login-container">
    <div class="logo">📸</div>
    <h2>Login to Image Gallery</h2>
    
    <% 
    String error = (String) request.getAttribute("error");
    String successMessage = (String) session.getAttribute("successMessage");
    
    if (successMessage != null) {
    %>
        <div class="success"><%= successMessage %></div>
    <%
        session.removeAttribute("successMessage");
    }
    
    if (error != null) {
    %>
        <div class="error"><%= error %></div>
    <% } %>
    
    <form action="LoginServlet" method="post">
        <div class="form-group">
            <label>Username</label>
            <input type="text" name="username" required autofocus>
        </div>
        
        <div class="form-group">
            <label>Password</label>
            <input type="password" name="password" required>
        </div>
        
        <button type="submit" class="btn">Login</button>
    </form>
    
    <div class="signup-link">
        Don't have an account? <a href="signup.jsp">Sign up here</a>
    </div>
</div>
</body>
</html>