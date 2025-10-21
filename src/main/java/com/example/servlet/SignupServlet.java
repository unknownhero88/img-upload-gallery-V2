package com.example.servlet;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.example.util.*;

@WebServlet("/SignupServlet")
public class SignupServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String fullName = request.getParameter("fullName");
        
        // Validation
        if (username == null || email == null || password == null || 
            username.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "All fields are required");
            request.getRequestDispatcher("signup.jsp").forward(request, response);
            return;
        }
        
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match");
            request.getRequestDispatcher("signup.jsp").forward(request, response);
            return;
        }
        
        if (password.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters");
            request.getRequestDispatcher("signup.jsp").forward(request, response);
            return;
        }
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            
            // Check if username or email already exists
            String checkSql = "SELECT id FROM users WHERE username = ? OR email = ?";
            ps = conn.prepareStatement(checkSql);
            ps.setString(1, username);
            ps.setString(2, email);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                request.setAttribute("error", "Username or email already exists");
                request.getRequestDispatcher("signup.jsp").forward(request, response);
                return;
            }
            
            rs.close();
            ps.close();
            
            // Insert new user
            String insertSql = "INSERT INTO users (username, email, password, full_name, is_active) VALUES (?, ?, ?, ?, TRUE)";
            ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, username);
            ps.setString(2, email);
            ps.setString(3, PasswordUtil.hashPassword(password));
            ps.setString(4, fullName);
            
            int rowsAffected = ps.executeUpdate();
            
            if (rowsAffected > 0) {
                // Get generated user ID
                rs = ps.getGeneratedKeys();
                int userId = 0;
                if (rs.next()) {
                    userId = rs.getInt(1);
                }
                
                // Log activity
                ActivityLogger.log(userId, "SIGNUP", "New user account created", request);
                
                // Redirect to login with success message
                HttpSession session = request.getSession();
                session.setAttribute("successMessage", "Account created successfully! Please login.");
                response.sendRedirect("login.jsp");
            } else {
                request.setAttribute("error", "Failed to create account");
                request.getRequestDispatcher("signup.jsp").forward(request, response);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("signup.jsp").forward(request, response);
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("signup.jsp");
    }
}