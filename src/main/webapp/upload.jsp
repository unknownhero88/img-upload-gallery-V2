<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Upload Image</title>
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
    background: white;
    padding: 40px;
    border-radius: 20px;
    box-shadow: 0 10px 40px rgba(0,0,0,0.2);
    max-width: 500px;
    width: 100%;
}

h2 {
    text-align: center;
    color: #333;
    margin-bottom: 30px;
    font-size: 2rem;
}

.upload-area {
    border: 3px dashed #667eea;
    border-radius: 15px;
    padding: 40px;
    text-align: center;
    cursor: pointer;
    transition: all 0.3s;
    background: #f8f9fa;
}

.upload-area:hover {
    border-color: #764ba2;
    background: #e9ecef;
}

.upload-area.dragover {
    background: #e7e9fc;
    border-color: #764ba2;
}

.upload-icon {
    font-size: 3rem;
    margin-bottom: 15px;
}

input[type="file"] {
    display: none;
}

.file-name {
    margin-top: 15px;
    color: #28a745;
    font-weight: bold;
}

.preview {
    margin-top: 20px;
    text-align: center;
}

.preview img {
    max-width: 100%;
    max-height: 300px;
    border-radius: 10px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.btn {
    width: 100%;
    padding: 15px;
    border: none;
    border-radius: 10px;
    font-size: 16px;
    font-weight: bold;
    cursor: pointer;
    margin-top: 20px;
    transition: all 0.3s;
}

.btn-upload {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
}

.btn-upload:hover {
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
}

.btn-upload:disabled {
    background: #ccc;
    cursor: not-allowed;
    transform: none;
}

.btn-back {
    background: #6c757d;
    color: white;
    display: inline-block;
    text-decoration: none;
    text-align: center;
}

.btn-back:hover {
    background: #5a6268;
}

.loading {
    display: none;
    text-align: center;
    margin-top: 20px;
}

.spinner {
    border: 4px solid #f3f3f3;
    border-top: 4px solid #667eea;
    border-radius: 50%;
    width: 40px;
    height: 40px;
    animation: spin 1s linear infinite;
    margin: 0 auto;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

.note {
    text-align: center;
    color: #666;
    font-size: 14px;
    margin-top: 15px;
}
</style>
</head>
<body>
<div class="container">
    <h2>📤 Upload Image</h2>
    
    <form id="uploadForm" action="UploadImageServlet" method="post" enctype="multipart/form-data">
        <div class="upload-area" id="uploadArea">
            <div class="upload-icon">☁️</div>
            <h3>Drag & Drop Image Here</h3>
            <p>or click to browse</p>
            <input type="file" name="image" id="fileInput" accept="image/*" required>
        </div>
        
        <div class="file-name" id="fileName"></div>
        
        <div class="preview" id="preview"></div>
        
        <button type="submit" class="btn btn-upload" id="uploadBtn" disabled>
            Upload Image
        </button>
        
        <div class="loading" id="loading">
            <div class="spinner"></div>
            <p>Uploading...</p>
        </div>
        
        <a href="show.jsp" class="btn btn-back">← Back to Gallery</a>
        
        <div class="note">
            Max file size: 5MB | Supported: JPG, PNG, GIF
        </div>
    </form>
</div>

<script>
const uploadArea = document.getElementById('uploadArea');
const fileInput = document.getElementById('fileInput');
const fileName = document.getElementById('fileName');
const preview = document.getElementById('preview');
const uploadBtn = document.getElementById('uploadBtn');
const uploadForm = document.getElementById('uploadForm');
const loading = document.getElementById('loading');

// Click to upload
uploadArea.addEventListener('click', () => {
    fileInput.click();
});

// File selected
fileInput.addEventListener('change', (e) => {
    handleFile(e.target.files[0]);
});

// Drag and drop
uploadArea.addEventListener('dragover', (e) => {
    e.preventDefault();
    uploadArea.classList.add('dragover');
});

uploadArea.addEventListener('dragleave', () => {
    uploadArea.classList.remove('dragover');
});

uploadArea.addEventListener('drop', (e) => {
    e.preventDefault();
    uploadArea.classList.remove('dragover');
    
    const file = e.dataTransfer.files[0];
    if (file && file.type.startsWith('image/')) {
        fileInput.files = e.dataTransfer.files;
        handleFile(file);
    } else {
        alert('Please drop an image file!');
    }
});

function handleFile(file) {
    if (!file) return;
    
    // Validate file type
    if (!file.type.startsWith('image/')) {
        alert('Please select an image file!');
        return;
    }
    
    // Validate file size (5MB)
    if (file.size > 5 * 1024 * 1024) {
        alert('File size must be less than 5MB!');
        return;
    }
    
    // Show file name
    fileName.textContent = `Selected: ${file.name}`;
    
    // Show preview
    const reader = new FileReader();
    reader.onload = (e) => {
        preview.innerHTML = `<img src="${e.target.result}" alt="Preview">`;
    };
    reader.readAsDataURL(file);
    
    // Enable upload button
    uploadBtn.disabled = false;
}

// Form submission
uploadForm.addEventListener('submit', () => {
    uploadBtn.disabled = true;
    uploadBtn.textContent = 'Uploading...';
    loading.style.display = 'block';
});
</script>
</body>
</html>