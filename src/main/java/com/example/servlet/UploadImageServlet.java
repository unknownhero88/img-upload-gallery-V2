package com.example.servlet;

import java.io.*;
import java.net.*;
import java.sql.*;
import org.json.JSONObject;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import java.awt.Image;
import com.example.util.DatabaseUtil;
import com.example.util.ActivityLogger;

@WebServlet("/UploadImageServlet")
@MultipartConfig(
    maxFileSize = 5242880,      // 5MB
    maxRequestSize = 10485760   // 10MB
)
public class UploadImageServlet extends HttpServlet {
    
    private static final String IMGBB_API_KEY = System.getenv("IMGBB_API_KEY") != null 
        ? System.getenv("IMGBB_API_KEY")
        : "34d8f020849d0373dd10544fb315c979";
    
    
    // Image compression settings
    private static final int MAX_WIDTH = 1920;
    private static final int MAX_HEIGHT = 1080;
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        Integer userId = (Integer) session.getAttribute("userId");
        
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            // Get uploaded file
            Part filePart = request.getPart("image");
            
            if (filePart == null || filePart.getSize() == 0) {
                sendErrorResponse(out, "No file selected!");
                return;
            }
            
            // Validate file type
            String contentType = filePart.getContentType();
            if (!isValidImageType(contentType)) {
                sendErrorResponse(out, "Please upload only image files (JPG, PNG, GIF)!");
                return;
            }
            
            // Check original file size
            long originalSize = filePart.getSize();
            System.out.println("Original file size: " + (originalSize / 1024) + " KB");
            
            // Compress and convert to Base64
            String base64Image = compressAndConvertToBase64(filePart);
            
            if (base64Image == null) {
                sendErrorResponse(out, "Failed to process image. Please try another image.");
                return;
            }
            
            System.out.println("Compressed Base64 length: " + base64Image.length());
            
            // Upload to ImgBB
            String imageUrl = uploadToImgBB(base64Image);
            
            if (imageUrl != null) {
                // Store URL in MySQL with user_id
                boolean stored = storeImageUrlInDatabase(imageUrl, userId);
                
                // Log activity
                ActivityLogger.log(userId, "IMAGE_UPLOAD", "Uploaded new image", request);
                
                // Success response with redirect
                sendSuccessResponse(out, imageUrl, stored, originalSize);
            } else {
                sendErrorResponse(out, "Upload to ImgBB failed. Please check your API key or try again.");
            }
            
        } catch (Exception e) {
            System.err.println("Error in doPost: " + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(out, "Server error: " + e.getMessage());
        } finally {
            out.close();
        }
    }
    
    private boolean isValidImageType(String contentType) {
        return contentType != null && 
               (contentType.equals("image/jpeg") || 
                contentType.equals("image/jpg") || 
                contentType.equals("image/png") || 
                contentType.equals("image/gif") ||
                contentType.equals("image/webp"));
    }
    
    private String compressAndConvertToBase64(Part filePart) {
        InputStream inputStream = null;
        try {
            // Get fresh input stream
            inputStream = filePart.getInputStream();
            
            // Read original image
            BufferedImage originalImage = ImageIO.read(inputStream);
            
            if (originalImage == null) {
                System.err.println("Failed to read image - ImageIO returned null");
                // Fallback: read as bytes directly
                return readDirectly(filePart);
            }
            
            // Get original dimensions
            int originalWidth = originalImage.getWidth();
            int originalHeight = originalImage.getHeight();
            
            System.out.println("Original dimensions: " + originalWidth + "x" + originalHeight);
            
            // Calculate new dimensions (maintain aspect ratio)
            int newWidth = originalWidth;
            int newHeight = originalHeight;
            
            if (originalWidth > MAX_WIDTH || originalHeight > MAX_HEIGHT) {
                double widthRatio = (double) MAX_WIDTH / originalWidth;
                double heightRatio = (double) MAX_HEIGHT / originalHeight;
                double ratio = Math.min(widthRatio, heightRatio);
                
                newWidth = (int) (originalWidth * ratio);
                newHeight = (int) (originalHeight * ratio);
                
                System.out.println("Resizing to: " + newWidth + "x" + newHeight);
            }
            
            // Create resized image
            BufferedImage resizedImage;
            if (newWidth != originalWidth || newHeight != originalHeight) {
                resizedImage = new BufferedImage(newWidth, newHeight, BufferedImage.TYPE_INT_RGB);
                resizedImage.createGraphics().drawImage(
                    originalImage.getScaledInstance(newWidth, newHeight, Image.SCALE_SMOOTH),
                    0, 0, null
                );
            } else {
                // Convert to RGB if not already
                if (originalImage.getType() != BufferedImage.TYPE_INT_RGB) {
                    resizedImage = new BufferedImage(originalWidth, originalHeight, BufferedImage.TYPE_INT_RGB);
                    resizedImage.createGraphics().drawImage(originalImage, 0, 0, null);
                } else {
                    resizedImage = originalImage;
                }
            }
            
            // Convert to JPEG with compression
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            
            // Write as JPEG
            boolean written = ImageIO.write(resizedImage, "jpg", baos);
            
            if (!written || baos.size() == 0) {
                System.err.println("ImageIO.write failed or returned empty");
                // Fallback: read directly
                return readDirectly(filePart);
            }
            
            byte[] imageBytes = baos.toByteArray();
            System.out.println("Compressed size: " + (imageBytes.length / 1024) + " KB");
            
            // Convert to Base64
            String base64 = java.util.Base64.getEncoder().encodeToString(imageBytes);
            
            if (base64 == null || base64.isEmpty()) {
                System.err.println("Base64 encoding returned empty");
                return readDirectly(filePart);
            }
            
            return base64;
            
        } catch (Exception e) {
            System.err.println("Error compressing image: " + e.getMessage());
            e.printStackTrace();
            // Fallback: read directly
            try {
                return readDirectly(filePart);
            } catch (Exception ex) {
                System.err.println("Fallback also failed: " + ex.getMessage());
                return null;
            }
        } finally {
            if (inputStream != null) {
                try {
                    inputStream.close();
                } catch (IOException e) {
                    // Ignore
                }
            }
        }
    }
    
    // Fallback method: read image directly without compression
    private String readDirectly(Part filePart) throws IOException {
        System.out.println("Using fallback: reading image directly...");
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try (InputStream is = filePart.getInputStream()) {
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = is.read(buffer)) != -1) {
                baos.write(buffer, 0, bytesRead);
            }
        }
        byte[] imageBytes = baos.toByteArray();
        System.out.println("Direct read size: " + (imageBytes.length / 1024) + " KB");
        return java.util.Base64.getEncoder().encodeToString(imageBytes);
    }
    
    private String uploadToImgBB(String base64Image) {
        HttpURLConnection conn = null;
        try {
            System.out.println("Starting upload to ImgBB...");
            
            URL url = new URL("https://api.imgbb.com/1/upload");
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            conn.setConnectTimeout(30000);  // 30 seconds
            conn.setReadTimeout(30000);     // 30 seconds
            
            // Send POST data
            String postData = "key=" + URLEncoder.encode(IMGBB_API_KEY, "UTF-8") +
                            "&image=" + URLEncoder.encode(base64Image, "UTF-8");
            
            try (OutputStream os = conn.getOutputStream()) {
                os.write(postData.getBytes("UTF-8"));
                os.flush();
            }
            
            System.out.println("Data sent, waiting for response...");
            
            // Check response code
            int responseCode = conn.getResponseCode();
            System.out.println("Response code: " + responseCode);
            
            if (responseCode != 200) {
                // Read error response
                try (BufferedReader errorReader = new BufferedReader(
                        new InputStreamReader(conn.getErrorStream()))) {
                    String errorLine;
                    StringBuilder errorMsg = new StringBuilder();
                    while ((errorLine = errorReader.readLine()) != null) {
                        errorMsg.append(errorLine);
                    }
                    System.err.println("ImgBB API Error: " + errorMsg.toString());
                }
                return null;
            }
            
            // Read response
            StringBuilder responseStr = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(conn.getInputStream(), "UTF-8"))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    responseStr.append(line);
                }
            }
            
            System.out.println("Response received");
            
            // Parse JSON response
            JSONObject json = new JSONObject(responseStr.toString());
            if (json.getBoolean("success")) {
                String imageUrl = json.getJSONObject("data").getString("url");
                System.out.println("Upload successful: " + imageUrl);
                return imageUrl;
            }
            
        } catch (Exception e) {
            System.err.println("Error uploading to ImgBB: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
        return null;
    }
    
    private boolean storeImageUrlInDatabase(String imageUrl, int userId) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DatabaseUtil.getConnection();

            String sql = "INSERT INTO images (user_id, image_url, uploaded_at) VALUES (?, ?, NOW())";
            ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, imageUrl);

            int rowsAffected = ps.executeUpdate();
            System.out.println("Database insert: " + (rowsAffected > 0 ? "Success" : "Failed"));
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("Database error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (ps != null) ps.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
            DatabaseUtil.closeConnection(con);
        }
        return false;
    }

    
    private void sendSuccessResponse(PrintWriter out, String imageUrl, boolean stored, long originalSize) {
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<meta name='viewport' content='width=device-width, initial-scale=1.0'>");
        out.println("<title>Upload Success</title>");
        out.println("<style>");
        out.println("body { font-family: Arial; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; margin: 0; }");
        out.println(".container { background: white; padding: 30px; border-radius: 15px; max-width: 600px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }");
        out.println("h3 { color: #28a745; margin-bottom: 20px; }");
        out.println("img { max-width: 100%; border-radius: 8px; margin: 20px 0; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }");
        out.println(".info { background: #f8f9fa; padding: 15px; border-radius: 8px; margin: 15px 0; }");
        out.println(".btn { display: inline-block; background: #667eea; color: white; padding: 10px 25px; border-radius: 25px; text-decoration: none; margin: 10px 5px; }");
        out.println(".btn:hover { opacity: 0.9; }");
        out.println("a { color: #007bff; word-break: break-all; }");
        out.println("</style>");
        out.println("</head>");
        out.println("<body>");
        out.println("<div class='container'>");
        out.println("<h3>✓ Image Uploaded Successfully!</h3>");
        out.println("<div class='info'>");
        out.println("<strong>Image URL:</strong><br>");
        out.println("<a href='" + imageUrl + "' target='_blank'>" + imageUrl + "</a>");
        out.println("</div>");
        out.println("<div class='info'>");
        out.println("<strong>Original Size:</strong> " + (originalSize / 1024) + " KB<br>");
        out.println("<strong>Database Status:</strong> " + (stored ? "✓ Saved" : "✗ Failed") + "<br>");
        out.println("</div>");
        out.println("<img src='" + imageUrl + "' alt='Uploaded Image'>");
        out.println("<div>");
        out.println("<a href='upload.html' class='btn'>Upload Another</a>");
        out.println("<a href='gallery.jsp' class='btn'>View Gallery</a>");
        out.println("</div>");
        out.println("</div>");
        out.println("</body>");
        out.println("</html>");
    }
    
    private void sendErrorResponse(PrintWriter out, String message) {
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<title>Upload Error</title>");
        out.println("<style>");
        out.println("body { font-family: Arial; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; margin: 0; }");
        out.println(".container { background: white; padding: 30px; border-radius: 15px; max-width: 500px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }");
        out.println("h3 { color: #dc3545; }");
        out.println(".btn { display: inline-block; background: #667eea; color: white; padding: 10px 25px; border-radius: 25px; text-decoration: none; margin-top: 20px; }");
        out.println("</style>");
        out.println("</head>");
        out.println("<body>");
        out.println("<div class='container'>");
        out.println("<h3>✗ Upload Failed!</h3>");
        out.println("<p>" + message + "</p>");
        out.println("<a href='javascript:history.back()' class='btn'>Go Back</a>");
        out.println("</div>");
        out.println("</body>");
        out.println("</html>");
    }
}