package com.example.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import jakarta.servlet.http.HttpServletRequest;

public class ActivityLogger {
    
    public static void log(int userId, String action, String description, HttpServletRequest request) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            
            String sql = "INSERT INTO activity_logs (user_id, action, description, ip_address, user_agent) VALUES (?, ?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, action);
            ps.setString(3, description);
            ps.setString(4, getClientIP(request));
            ps.setString(5, request.getHeader("User-Agent"));
            
            ps.executeUpdate();
            
        } catch (Exception e) {
            System.err.println("Error logging activity: " + e.getMessage());
        } finally {
            try {
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    public static void log(int userId, String action, HttpServletRequest request) {
        log(userId, action, null, request);
    }
    
    private static String getClientIP(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("X-Real-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        return ip;
    }
}