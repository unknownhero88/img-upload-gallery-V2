<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Sign Up - Image Gallery</title>
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

.signup-container {
    background: white;
    padding: 40px;
    border-radius: 20px;
    box-shadow: 0 20px 60px rgba(0,0,0,0.3);
    max-width: 450px;
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
input[type="email"],
input[type="password"] {
    width: 100%;
    padding: 12px 15px;
    border: 2px solid #e0e0e0;
    border-radius: 10px;
    font-size: 14px;
    transition: border 0.3s;
}

input:focus {
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

.login-link {
    text-align: center;
    margin-top: 20px;
    color: #666;
}

.login-link a {
    color: #667eea;
    text-decoration: none;
    font-weight: bold;
}

.login-link a:hover {
    text-decoration: underline;
}

.password-strength {
    height: 4px;
    background: #e0e0e0;
    border-radius: 2px;
    margin-top: 8px;
    overflow: hidden;
}

.password-strength-bar {
    height: 100%;
    width: 0;
    transition: all 0.3s;
}

.weak { width: 33%; background: #ff4444; }
.medium { width: 66%; background: #ffaa00; }
.strong { width: 100%; background: #00cc66; }
</style>
</head>
<body>
<div class="signup-container">
    <div class="logo">📸</div>
    <h2>Create Your Account</h2>
    
    <% String error = (String) request.getAttribute("error");
       if (error != null) { %>
        <div class="error"><%= error %></div>
    <% } %>
    
    <form action="SignupServlet" method="post" onsubmit="return validateForm()">
        <div class="form-group">
            <label>Full Name</label>
            <input type="text" name="fullName" id="fullName" placeholder="Enter your full name">
        </div>
        
        <div class="form-group">
            <label>Username *</label>
            <input type="text" name="username" id="username" required placeholder="Choose a username">
        </div>
        
        <div class="form-group">
            <label>Email *</label>
            <input type="email" name="email" id="email" required placeholder="your@email.com">
        </div>
        
        <div class="form-group">
            <label>Password *</label>
            <input type="password" name="password" id="password" required 
                   placeholder="At least 6 characters" onkeyup="checkPasswordStrength()">
            <div class="password-strength">
                <div class="password-strength-bar" id="strengthBar"></div>
            </div>
        </div>
        
        <div class="form-group">
            <label>Confirm Password *</label>
            <input type="password" name="confirmPassword" id="confirmPassword" required 
                   placeholder="Re-enter password">
        </div>
        
        <button type="submit" class="btn">Create Account</button>
    </form>
    
    <div class="login-link">
        Already have an account? <a href="login.jsp">Login here</a>
    </div>
</div>

<script>
function checkPasswordStrength() {
    const password = document.getElementById('password').value;
    const bar = document.getElementById('strengthBar');
    
    bar.className = 'password-strength-bar';
    
    if (password.length === 0) {
        bar.style.width = '0';
    } else if (password.length < 6) {
        bar.classList.add('weak');
    } else if (password.length < 10) {
        bar.classList.add('medium');
    } else {
        bar.classList.add('strong');
    }
}

function validateForm() {
    const password = document.getElementById('password').value;
    const confirmPassword = document.getElementById('confirmPassword').value;
    
    if (password !== confirmPassword) {
        alert('Passwords do not match!');
        return false;
    }
    
    if (password.length < 6) {
        alert('Password must be at least 6 characters long!');
        return false;
    }
    
    return true;
}
</script>
</body>
</html>