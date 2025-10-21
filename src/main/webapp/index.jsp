<%@ page contentType="text/html;charset=UTF-8" %>
<%
    // Check if user is already logged in
    if (session.getAttribute("user") != null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Image Gallery App</title>
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

.container {
    text-align: center;
    max-width: 800px;
    width: 100%;
}

.hero {
    background: rgba(255, 255, 255, 0.95);
    padding: 60px 40px;
    border-radius: 25px;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(10px);
}

.logo {
    font-size: 4rem;
    margin-bottom: 20px;
    animation: float 3s ease-in-out infinite;
}

@keyframes float {
    0%, 100% { transform: translateY(0px); }
    50% { transform: translateY(-20px); }
}

h1 {
    color: #333;
    font-size: 2.5rem;
    margin-bottom: 10px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

.subtitle {
    color: #666;
    font-size: 1.1rem;
    margin-bottom: 40px;
}

.card-container {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 25px;
    margin-top: 40px;
}

.card {
    background: white;
    padding: 40px 30px;
    border-radius: 20px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
    transition: all 0.3s ease;
    cursor: pointer;
    text-decoration: none;
    display: block;
    position: relative;
    overflow: hidden;
}

.card::before {
    content: '';
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(90deg, transparent, rgba(102, 126, 234, 0.1), transparent);
    transition: left 0.5s;
}

.card:hover::before {
    left: 100%;
}

.card:hover {
    transform: translateY(-10px);
    box-shadow: 0 15px 40px rgba(102, 126, 234, 0.3);
}

.card-icon {
    font-size: 3.5rem;
    margin-bottom: 20px;
    display: block;
}

.card-title {
    color: #333;
    font-size: 1.5rem;
    font-weight: bold;
    margin-bottom: 10px;
}

.card-description {
    color: #666;
    font-size: 0.95rem;
    line-height: 1.5;
}

.card.primary {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.card.primary .card-title,
.card.primary .card-description {
    color: white;
}

.features {
    display: flex;
    justify-content: center;
    gap: 30px;
    margin-top: 40px;
    flex-wrap: wrap;
}

.feature {
    display: flex;
    align-items: center;
    gap: 10px;
    color: white;
    font-size: 0.9rem;
    background: rgba(255, 255, 255, 0.2);
    padding: 10px 20px;
    border-radius: 50px;
    backdrop-filter: blur(10px);
    box-shadow: 0 15px 40px rgba(102, 126, 234, 0.3);
}

.feature-icon {
    font-size: 1.2rem;
}
#feature-text {
	color: black;
}

footer {
    margin-top: 40px;
    color: white;
    font-size: 0.9rem;
    opacity: 0.8;
}

@media (max-width: 768px) {
    .hero {
        padding: 40px 25px;
    }
    
    h1 {
        font-size: 2rem;
    }
    
    .card-container {
        grid-template-columns: 1fr;
    }
    
    .features {
        flex-direction: column;
        gap: 15px;
    }
}
</style>
</head>
<body>
<div class="container">
    <div class="hero">
        <div class="logo">📸</div>
        <h1>Image Gallery App</h1>
        <p class="subtitle">Upload, manage, and showcase your images beautifully</p>
        
        <div class="card-container">
            <a href="login.jsp" class="card primary">
                <span class="card-icon">🔐</span>
                <h3 class="card-title">Login</h3>
                <p class="card-description">Access your account and manage your images</p>
            </a>
            
            <a href="signup.jsp" class="card">
                <span class="card-icon">✨</span>
                <h3 class="card-title">Sign Up</h3>
                <p class="card-description">Create a new account and start uploading</p>
            </a>
        </div>
        
        <div class="features">
            <div class="feature">
                <span class="feature-icon">⚡</span>
                <span id='feature-text'>Fast Upload</span>
            </div>
            <div class="feature">
                <span class="feature-icon">🔒</span>
                <span id='feature-text'>Secure Storage</span>
            </div>
            <div class="feature">
                <span class="feature-icon">📱</span>
                <span id='feature-text'>Mobile Friendly</span>
            </div>
            <div class="feature">
                <span class="feature-icon">🎨</span>
                <span id='feature-text'>Beautiful UI</span>
            </div>
            <div class="feature">
                <span class="feature-icon">📊</span>
                <span id='feature-text'>Activity Tracking</span>
            </div>
        </div>
    </div>
    
    <footer>
        <p>Built with ❤️ using Java Servlets, MySQL & ImgBB API</p>
    </footer>
</div>

<script>
// Add smooth loading effect
window.addEventListener('load', () => {
    document.querySelector('.hero').style.opacity = '0';
    document.querySelector('.hero').style.transform = 'translateY(30px)';
    
    setTimeout(() => {
        document.querySelector('.hero').style.transition = 'all 0.8s ease';
        document.querySelector('.hero').style.opacity = '1';
        document.querySelector('.hero').style.transform = 'translateY(0)';
    }, 100);
});

// Add click ripple effect
document.querySelectorAll('.card').forEach(card => {
    card.addEventListener('click', function(e) {
        const ripple = document.createElement('div');
        ripple.style.position = 'absolute';
        ripple.style.borderRadius = '50%';
        ripple.style.background = 'rgba(255, 255, 255, 0.5)';
        ripple.style.width = ripple.style.height = '100px';
        ripple.style.left = e.clientX - this.offsetLeft - 50 + 'px';
        ripple.style.top = e.clientY - this.offsetTop - 50 + 'px';
        ripple.style.animation = 'ripple 0.6s ease-out';
        ripple.style.pointerEvents = 'none';
        
        this.appendChild(ripple);
        
        setTimeout(() => ripple.remove(), 600);
    });
});

// Add ripple animation
const style = document.createElement('style');
style.textContent = `
    @keyframes ripple {
        to {
            transform: scale(4);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);
</script>
</body>
</html>